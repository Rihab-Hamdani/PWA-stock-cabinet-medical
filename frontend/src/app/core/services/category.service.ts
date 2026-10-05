import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Category, CategoryTrash } from '../models/models';

export interface CategoryCreateRequest {
  nom: string;
  produitNom: string;
  unite: string;
  seuilAlerte: number;
}

@Injectable({ providedIn: 'root' })
export class CategoryService {
  private http = inject(HttpClient);

  list(nom?: string): Observable<Category[]> {
    const params: Record<string, string> = {};
    if (nom) params['nom'] = nom;
    return this.http.get<Category[]>(`${environment.api}/categories`, { params });
  }

  create(payload: CategoryCreateRequest): Observable<void> {
    return this.http.post<void>(`${environment.api}/categories`, payload);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${environment.api}/categories/${id}`);
  }

  listTrash(): Observable<CategoryTrash[]> {
    return this.http.get<CategoryTrash[]>(`${environment.api}/categories/corbeille`);
  }

  restore(id: string): Observable<void> {
    return this.http.post<void>(`${environment.api}/categories/${id}/restaurer`, {});
  }

  deletePermanently(id: string): Observable<void> {
    return this.http.delete<void>(`${environment.api}/categories/${id}/definitif`);
  }
}