import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Product } from '../models/models';

export interface ProductRequest {
  nom: string;
  categorieId: string;
  unite: string;
  seuilAlerte: number;
  prixUnitaireHt: number;
  datePeremption?: string | null;
  numeroLot?: string | null;
}

export interface MovementEntreeRequest {
  quantite: number;
  prixUnitaireHt: number;
  fournisseurId?: string | null;
  fournisseurNom?: string | null;
  fournisseurTelephone?: string | null;
  numeroFacture?: string | null;
}

@Injectable({ providedIn: 'root' })
export class ProductService {
  private http = inject(HttpClient);

  list(categorieId?: string, nom?: string): Observable<Product[]> {
    const params: Record<string, string> = {};
    if (categorieId) params['categorieId'] = categorieId;
    if (nom) params['nom'] = nom;
    return this.http.get<Product[]>(`${environment.api}/products`, { params });
  }

  create(request: ProductRequest): Observable<{ id: string }> {
  return this.http.post<{ id: string }>(`${environment.api}/products`, request);
}

  update(id: string, request: ProductRequest): Observable<void> {
    return this.http.put<void>(`${environment.api}/products/${id}`, request);
  }

  deactivate(id: string): Observable<void> {
    return this.http.patch<void>(`${environment.api}/products/${id}/desactiver`, {});
  }

  sortieRapide(id: string): Observable<void> {
    return this.http.post<void>(`${environment.api}/movements/${id}/sortie-rapide`, {});
  }

  enregistrerArrivage(produitId: string, request: MovementEntreeRequest): Observable<void> {
    return this.http.post<void>(`${environment.api}/movements/${produitId}/entree`, request);
  }

  getUnites(): Observable<string[]> {
    return this.http.get<string[]>(`${environment.api}/products/unites`);
  }
}