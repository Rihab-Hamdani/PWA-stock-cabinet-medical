import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { MovementHistorique } from '../models/models';

@Injectable({ providedIn: 'root' })
export class MovementService {
  private http = inject(HttpClient);

  historiqueProduit(produitId: string): Observable<MovementHistorique[]> {
    return this.http.get<MovementHistorique[]>(`${environment.api}/movements/produit/${produitId}`);
  }
}