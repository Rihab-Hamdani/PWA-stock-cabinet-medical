import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { RouterLink } from '@angular/router';
import { PatientService } from '../../../core/services/patient.service';
import { PatientDto } from '../../../core/models/models';

@Component({
  selector: 'app-patient-history',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './patient-history.component.html',
  styleUrl: './patient-history.component.scss'
})
export class PatientHistoryComponent implements OnInit {
  private patientService = inject(PatientService);

  patients = signal<PatientDto[]>([]);
  chargement = signal(true);
  jourOuvert = signal<string | null>(null);

  joursGroupes = computed(() => {
    const groupes = new Map<string, PatientDto[]>();
    for (const p of this.patients()) {
      const cle = p.dateRdv || 'Sans date';
      if (!groupes.has(cle)) groupes.set(cle, []);
      groupes.get(cle)!.push(p);
    }
    return Array.from(groupes.entries())
      .sort((a, b) => b[0].localeCompare(a[0]))
      .map(([date, liste]) => ({ date, liste }));
  });

  ngOnInit(): void {
    this.patientService.list().subscribe({
      next: (p) => { this.patients.set(p); this.chargement.set(false); },
      error: () => this.chargement.set(false)
    });
  }

  toggleJour(date: string): void {
    this.jourOuvert.set(this.jourOuvert() === date ? null : date);
  }
}