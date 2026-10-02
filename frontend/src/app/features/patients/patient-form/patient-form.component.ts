import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { PatientService } from '../../../core/services/patient.service';

@Component({
  selector: 'app-patient-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './patient-form.component.html',
  styleUrl: './patient-form.component.scss'
})
export class PatientFormComponent {
  private fb = inject(FormBuilder);
  private patientService = inject(PatientService);
  private router = inject(Router);

  chargement = signal(false);
  erreur = signal('');

  examens = ['EEG de veille', 'EEG de sommeil', 'EMG 2 membres', 'EMG 4 membres', 'EMG avec test myasthénie', 'PEA', 'PEV', 'ERG', 'PES', 'EFR / Spiro', 'Test cutané PVN', 'Autre'];
  medecins = ['Dr Dammak', 'Dr Bergaoui', 'Dr Manel', 'Autre'];
  cliniques = ['Echifa', 'La Douce', 'Internationale', 'Centre Arij', 'Autre'];

  form = this.fb.nonNullable.group({
    prenom: ['', Validators.required],
    nom: ['', Validators.required],
    email: [''],
    dateNaissance: [''],
    sexe: [''],
    telephone: [''],
    adresse: [''],
    examenDemande: [''],
    examenAutre: [''],
    medecinTraitant: [''],
    medecinAutre: [''],
    clinique: [''],
    cliniqueAutre: [''],
    dateRdv: [''],
    assurance: [''],
    montantPaye: [0],
    remarques: ['']
  });

  submit(): void {
    if (this.form.invalid) return;
    this.chargement.set(true);
    this.erreur.set('');

    const v = this.form.getRawValue();
    const payload = {
      prenom: v.prenom,
      nom: v.nom,
      email: v.email || null,
      dateNaissance: v.dateNaissance || null,
      sexe: v.sexe || null,
      telephone: v.telephone || null,
      adresse: v.adresse || null,
      examenDemande: (v.examenDemande === 'Autre' ? v.examenAutre : v.examenDemande) || null,
      medecinTraitant: (v.medecinTraitant === 'Autre' ? v.medecinAutre : v.medecinTraitant) || null,
      clinique: (v.clinique === 'Autre' ? v.cliniqueAutre : v.clinique) || null,
      dateRdv: v.dateRdv || null,
      assurance: v.assurance || null,
      montantPaye: v.montantPaye || 0,
      remarques: v.remarques || null
    };

    this.patientService.create(payload).subscribe({
      next: () => this.router.navigate(['/patients']),
      error: () => {
        this.chargement.set(false);
        this.erreur.set('Impossible d\'enregistrer.');
      }
    });
  }
}