import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { PatientService } from '../../../core/services/patient.service';
import { ConfirmService } from "../../../core/services/confirrm.service";
import { STATUTS_RDV, StatutRdv } from '../../../core/models/models';

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
  private confirmService = inject(ConfirmService);
  private fb = inject(FormBuilder);

  chargement = signal(true);
  enregistrement = signal(false);
  suppressionEnCours = signal(false);
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
    const id = this.route.snapshot.paramMap.get('id')!;
    this.patientService.get(id).subscribe({
      next: (p) => {
        const [adresse, adresseAutre] = this.choix(this.adresses, p.adresse);
        const [examenDemande, examenAutre] = this.choix(this.examens, p.examenDemande);
        const [medecinTraitant, medecinAutre] = this.choix(this.medecins, p.medecinTraitant);
        const [clinique, cliniqueAutre] = this.choix(this.cliniques, p.clinique);

        this.form.patchValue({
          prenom: p.prenom,
          nom: p.nom,
          email: p.email || '',
          dateNaissance: p.dateNaissance || '',
          sexe: p.sexe || '',
          telephone: p.telephone || '',
          adresse, adresseAutre,
          examenDemande, examenAutre,
          medecinTraitant, medecinAutre,
          clinique, cliniqueAutre,
          dateRdv: p.dateRdv || '',
          heureRdv: p.heureRdv ? p.heureRdv.substring(0, 5) : '',
          statut: p.statut || 'PLANIFIE',
          paye: !!p.paye,
          assurance: p.assurance || '',
          montantPaye: p.montantPaye || 0,
          remarques: p.remarques || ''
        });
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set('Patient introuvable.');
        this.chargement.set(false);
      }
    });
  }

  // Valeur connue de la liste, sinon « Autre » avec le texte saisi à la main
  private choix(liste: string[], valeur?: string | null): [string, string] {
    if (!valeur) return ['', ''];
    return liste.includes(valeur) ? [valeur, ''] : ['Autre', valeur];
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
      heureRdv: v.heureRdv || null,
      statut: v.statut as StatutRdv,
      paye: v.paye,
      assurance: v.assurance || null,
      montantPaye: v.montantPaye || 0,
      remarques: v.remarques || null
    };

    this.patientService.update(id, payload).subscribe({
      next: () => this.router.navigate(['/agenda']),
      error: () => {
        this.enregistrement.set(false);
        this.erreur.set("Impossible d'enregistrer les modifications.");
      }
    });
  }

  async supprimer(): Promise<void> {
    const nom = `${this.form.get('prenom')?.value ?? ''} ${this.form.get('nom')?.value ?? ''}`.trim();
    const ok = await this.confirmService.ask({
      titre: 'Supprimer le patient ?',
      message: `La fiche de ${nom || 'ce patient'} sera supprimée définitivement. Cette action est irréversible.`,
      texteConfirmer: 'Supprimer',
      danger: true
    });
    if (!ok) return;

    const id = this.route.snapshot.paramMap.get('id')!;
    this.suppressionEnCours.set(true);
    this.patientService.delete(id).subscribe({
      next: () => this.router.navigate(['/agenda']),
      error: (err) => {
        this.suppressionEnCours.set(false);
        alert(err?.error?.message || 'Impossible de supprimer ce patient.');
      }
    });
  }
}