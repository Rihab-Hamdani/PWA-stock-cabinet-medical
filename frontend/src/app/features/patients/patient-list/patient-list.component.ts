import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { PatientService } from '../../../core/services/patient.service';
import { PatientDto } from '../../../core/models/models';

@Component({
  selector: 'app-patient-list',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './patient-list.component.html',
  styleUrl: './patient-list.component.scss'
})
export class PatientListComponent implements OnInit {
  private patientService = inject(PatientService);

  patients = signal<PatientDto[]>([]);
  chargement = signal(true);

  ngOnInit(): void {
    this.patientService.list().subscribe({
      next: (p) => { this.patients.set(p); this.chargement.set(false); },
      error: () => this.chargement.set(false)
    });
  }
}