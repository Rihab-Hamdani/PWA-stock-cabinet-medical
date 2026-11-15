import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PatientService } from '../../../core/services/patient.service';
import { PatientDetail, STATUTS_RDV, StatutRdv } from '../../../core/models/models';

@Component({
  selector: 'app-patient-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './patient-form.component.html',
  styleUrl: './patient-form.component.scss'
})
export class PatientFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private patientService = inject(PatientService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  chargement = signal(false);
  erreur = signal('');

  statuts = STATUTS_RDV;
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
    heureRdv: [''],
    statut: ['PLANIFIE'],
    paye: [false],
    assurance: [''],
    montantPaye: [0],
    remarques: ['']
  });

  ngOnInit(): void {
    const date = this.route.snapshot.queryParamMap.get('date');
    const copie = this.route.snapshot.queryParamMap.get('copie');

    if (date) this.form.patchValue({ dateRdv: date });
    if (copie) {
      this.patientService.get(copie).subscribe({
        next: (p) => this.preremplir(p, date)
      });
    }
  }

  // Reprend l'identité et l'examen d'un rendez-vous existant ; date, heure, statut et paiement repartent à zéro
  private preremplir(p: PatientDetail, date: string | null): void {
    const [adresse, adresseAutre] = this.choix(this.adresses, p.adresse);
    const [examenDemande, examenAutre] = this.choix(this.examens, p.examenDemande);
    const [medecinTraitant, medecinAutre] = this.choix(this.medecins, p.medecinTraitant);
    const [clinique, cliniqueAutre] = this.choix(this.cliniques, p.clinique);

    this.form.patchValue({
      prenom: p.prenom,
      nom: p.nom,
      email: p.email ?? '',
      dateNaissance: p.dateNaissance ?? '',
      sexe: p.sexe ?? '',
      telephone: p.telephone ?? '',
      adresse, adresseAutre,
      examenDemande, examenAutre,
      medecinTraitant, medecinAutre,
      clinique, cliniqueAutre,
      assurance: p.assurance ?? '',
      dateRdv: date ?? '',
      heureRdv: '',
      statut: 'PLANIFIE',
      paye: false,
      montantPaye: 0,
      remarques: ''
    });
  }

  private choix(liste: string[], valeur?: string | null): [string, string] {
    if (!valeur) return ['', ''];
    return liste.includes(valeur) ? [valeur, ''] : ['Autre', valeur];
  }

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
      adresse: (v.adresse === 'Autre' ? v.adresseAutre : v.adresse) || null,
      examenDemande: (v.examenDemande === 'Autre' ? v.examenAutre : v.examenDemande) || null,
      medecinTraitant: (v.medecinTraitant === 'Autre' ? v.medecinAutre : v.medecinTraitant) || null,
      clinique: (v.clinique === 'Autre' ? v.cliniqueAutre : v.clinique) || null,
      dateRdv: v.dateRdv || null,
      heureRdv: v.heureRdv || null,
      statut: v.statut as StatutRdv,
      paye: v.paye,
      assurance: v.assurance || null,
      montantPaye: v.montantPaye || 0,
      remarques: v.remarques || null
    };

    this.patientService.create(payload).subscribe({
      next: () => this.router.navigate(['/agenda']),
      error: () => {
        this.chargement.set(false);
        this.erreur.set("Impossible d'enregistrer.");
      }
    });
  }
}