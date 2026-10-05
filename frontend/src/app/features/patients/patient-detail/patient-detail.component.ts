import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { PatientService } from '../../../core/services/patient.service';

@Component({
  selector: 'app-patient-detail',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './patient-detail.component.html',
  styleUrl: './patient-detail.component.scss'
})
export class PatientDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private patientService = inject(PatientService);
  private fb = inject(FormBuilder);

  chargement = signal(true);
  enregistrement = signal(false);
  erreur = signal('');

  examens = ['EEG de veille', 'EEG de sommeil', 'EMG 2 membres', 'EMG 4 membres', 'EMG avec test myasthénie', 'PEA', 'PEV', 'ERG', 'PES', 'EFR / Spiro', 'Test cutané PVN', 'Autre'];
  medecins = ['Dr Dammak', 'Dr Bergaoui', 'Dr Manel', 'Autre'];
  cliniques = ['Echifa', 'La Douce', 'Internationale', 'Centre Arij', 'Autre'];
  adresses = ['Libye', 'Djerba Houmt Souk', 'Médenine', 'Tataouine', 'Autre'];
  assurances = ['Assurance', 'CNAM', 'Non assuré'];

  form = this.fb.nonNullable.group({
    prenom: ['', Validators.required],
    nom: ['', Validators.required],
    email: [''],
    dateNaissance: [''],
    sexe: [''],
    telephone: [''],
    adresse: [''],
    adresseAutre: [''],
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

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.patientService.get(id).subscribe({
      next: (p) => {
        const adresseConnue = this.adresses.includes(p.adresse || '') ? p.adresse : (p.adresse ? 'Autre' : '');
        const examenConnu = this.examens.includes(p.examenDemande || '') ? p.examenDemande : (p.examenDemande ? 'Autre' : '');
        const medecinConnu = this.medecins.includes(p.medecinTraitant || '') ? p.medecinTraitant : (p.medecinTraitant ? 'Autre' : '');
        const cliniqueConnue = this.cliniques.includes(p.clinique || '') ? p.clinique : (p.clinique ? 'Autre' : '');

        this.form.patchValue({
          prenom: p.prenom,
          nom: p.nom,
          email: p.email || '',
          dateNaissance: p.dateNaissance || '',
          sexe: p.sexe || '',
          telephone: p.telephone || '',
          adresse: adresseConnue || '',
          adresseAutre: adresseConnue === 'Autre' ? p.adresse || '' : '',
          examenDemande: examenConnu || '',
          examenAutre: examenConnu === 'Autre' ? p.examenDemande || '' : '',
          medecinTraitant: medecinConnu || '',
          medecinAutre: medecinConnu === 'Autre' ? p.medecinTraitant || '' : '',
          clinique: cliniqueConnue || '',
          cliniqueAutre: cliniqueConnue === 'Autre' ? p.clinique || '' : '',
          dateRdv: p.dateRdv || '',
          assurance: p.assurance || '',
          montantPaye: p.montantPaye || 0,
          remarques: p.remarques || ''
        });
        this.chargement.set(false);
      },
      error: () => { this.erreur.set('Patient introuvable.'); this.chargement.set(false); }
    });
  }

  submit(): void {
    if (this.form.invalid) return;
    this.enregistrement.set(true);
    this.erreur.set('');

    const id = this.route.snapshot.paramMap.get('id')!;
    const v = this.form.getRawValue();

    const payload = {
      prenom: v.prenom,
      nom: v.nom,
      email: v.email || null,
      dateNaissance: v.dateNaissance || null,
      sexe: v.sexe || null,
      telephone: v.telephone || null,
      adresse: (v.adresse === 'Autre' ? v.adresseAutre : v.adresse) || null,
      examenDemande: (v.examenDemande === 'Autre' ? v.examenAutre : v.examenDemande) || null,
      medecinTraitant: (v.medecinTraitant === 'Autre' ? v.medecinAutre : v.medecinTraitant) || null,
      clinique: (v.clinique === 'Autre' ? v.cliniqueAutre : v.clinique) || null,
      dateRdv: v.dateRdv || null,
      assurance: v.assurance || null,
      montantPaye: v.montantPaye || 0,
      remarques: v.remarques || null
    };

    this.patientService.update(id, payload).subscribe({
      next: () => this.router.navigate(['/patients/historique']),
      error: () => {
        this.enregistrement.set(false);
        this.erreur.set("Impossible d'enregistrer les modifications.");
      }
    });
  }
}