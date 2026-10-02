import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Supplier } from '../models/models';

@Injectable({ providedIn: 'root' })
export class SupplierService {
  private http = inject(HttpClient);

  list(nom?: string): Observable<Supplier[]> {
    const params: Record<string, string> = {};
    if (nom) params['nom'] = nom;
    return this.http.get<Supplier[]>(`${environment.api}/suppliers`, { params });
  }

  create(nom: string, telephone?: string): Observable<void> {
    return this.http.post<void>(`${environment.api}/suppliers`, { nom, telephone });
  }
}