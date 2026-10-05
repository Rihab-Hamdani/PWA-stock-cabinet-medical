import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { User } from '../models/models';

@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);

  pending(): Observable<User[]> {
    return this.http.get<User[]>(`${environment.api}/users/pending`);
  }

  activate(id: string): Observable<void> {
    return this.http.patch<void>(`${environment.api}/users/${id}/activer`, {});
  }

  reject(id: string): Observable<void> {
    return this.
    http.delete<void>(`${environment.api}/users/${id}`);
  }

  updateMyProfile(payload: { prenom: string; nom: string; telephone?: string }): Observable<User> {
  return this.http.put<User>(`${environment.api}/users/me`, payload);
}

countPending(): Observable<number> {
  return this.http.get<number>(`${environment.api}/users/pending/count`);
}
}