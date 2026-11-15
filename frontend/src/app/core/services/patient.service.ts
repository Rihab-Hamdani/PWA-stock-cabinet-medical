import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { PatientDetail, PatientDto, PatientRequest, StatutRdv } from '../models/models';

@Injectable({ providedIn: 'root' })
export class PatientService {
  private http = inject(HttpClient);

  list(): Observable<PatientDto[]> {
    return this.http.get<PatientDto[]>(`${environment.api}/patients`);
  }

  agenda(du: string, au: string): Observable<PatientDto[]> {
    return this.http.get<PatientDto[]>(`${environment.api}/patients/agenda`, { params: { du, au } });
  }

  get(id: string): Observable<PatientDetail> {
    return this.http.get<PatientDetail>(`${environment.api}/patients/${id}`);
  }

  create(request: PatientRequest): Observable<void> {
    return this.http.post<void>(`${environment.api}/patients`, request);
  }

  update(id: string, request: PatientRequest): Observable<void> {
    return this.http.put<void>(`${environment.api}/patients/${id}`, request);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${environment.api}/patients/${id}`);
  }

  changerStatut(id: string, statut: StatutRdv): Observable<void> {
    return this.http.patch<void>(`${environment.api}/patients/${id}/statut`, { statut });
  }

  changerPaiement(id: string, paye: boolean, montantPaye?: number): Observable<void> {
    return this.http.patch<void>(`${environment.api}/patients/${id}/paiement`, { paye, montantPaye: montantPaye ?? null });
  }
}