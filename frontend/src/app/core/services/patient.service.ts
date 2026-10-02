import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { PatientDto, PatientRequest } from '../models/models';

@Injectable({ providedIn: 'root' })
export class PatientService {
  private http = inject(HttpClient);

  list(): Observable<PatientDto[]> {
    return this.http.get<PatientDto[]>(`${environment.api}/patients`);
  }

  create(request: PatientRequest): Observable<void> {
    return this.http.post<void>(`${environment.api}/patients`, request);
  }
}