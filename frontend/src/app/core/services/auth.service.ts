import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { LoginResponse, Role, User } from '../models/models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);

  private readonly TOKEN_KEY = 'stock_token';
  private readonly USER_KEY = 'stock_user';

  private currentUser = signal<User | null>(this.loadUser());

  readonly user = this.currentUser.asReadonly();
  readonly isLoggedIn = computed(() => this.currentUser() !== null);
  readonly isMedecin = computed(() => this.currentUser()?.role === 'MEDECIN');
  readonly role = computed<Role | null>(() => this.currentUser()?.role ?? null);

  login(email: string, motDePasse: string): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${environment.api}/auth/login`, { email, motDePasse })
      .pipe(tap((res) => this.setSession(res)));
  }

  register(nom: string, prenom: string, email: string, motDePasse: string): Observable<void> {
    return this.http.post<void>(`${environment.api}/auth/register`, { nom, prenom, email, motDePasse });
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.currentUser.set(null);
  }

  get token(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  /** Vérifie si l'utilisateur courant a l'un des rôles autorisés. */
  hasRole(...roles: Role[]): boolean {
    const r = this.currentUser()?.role;
    return r != null && roles.includes(r);
  }
  private loadUser(): User | null {
    const raw = localStorage.getItem(this.USER_KEY);
    return raw ? (JSON.parse(raw) as User) : null;
  }
  private setSession(res: LoginResponse): void {
  localStorage.setItem(this.TOKEN_KEY, res.token);
  localStorage.setItem(this.USER_KEY, JSON.stringify(res.user));
  this.currentUser.set(res.user);
}
forgotPassword(email: string): Observable<void> {
  return this.http.post<void>(`${environment.api}/auth/forgot-password`, { email });
}

resetPassword(token: string, nouveauMotDePasse: string): Observable<void> {
  return this.http.post<void>(`${environment.api}/auth/reset-password`, { token, nouveauMotDePasse });
}
}