import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { PatientService } from '../../core/services/patient.service';
import { PatientDto, STATUTS_RDV, StatutRdv } from '../../core/models/models';

interface Jour {
  date: string;
  numero: number;
  dansLeMois: boolean;
}

// Date locale au format YYYY-MM-DD (toISOString décalerait d'un jour selon le fuseau)
function iso(d: Date): string {
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const j = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${m}-${j}`;
}

function depuisIso(s: string): Date {
  const [a, m, j] = s.split('-').map(Number);
  return new Date(a, m - 1, j);
}

@Component({
  selector: 'app-agenda',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './agenda.component.html',
  styleUrl: './agenda.component.scss'
})
export class AgendaComponent implements OnInit {
  private patientService = inject(PatientService);
  private router = inject(Router);

  readonly joursSemaine = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  readonly statuts = STATUTS_RDV;
  readonly aujourdhuiIso = iso(new Date());

  moisCourant = signal(new Date(new Date().getFullYear(), new Date().getMonth(), 1));
  jourSelectionne = signal(iso(new Date()));
  rdvs = signal<PatientDto[]>([]);
  chargement = signal(true);
  erreur = signal('');

  grille = computed<Jour[]>(() => {
    const mois = this.moisCourant();
    const premier = new Date(mois.getFullYear(), mois.getMonth(), 1);
    const decalage = (premier.getDay() + 6) % 7; // semaine commençant le lundi
    const jours: Jour[] = [];
    for (let i = 0; i < 42; i++) {
      const d = new Date(mois.getFullYear(), mois.getMonth(), 1 - decalage + i);
      jours.push({ date: iso(d), numero: d.getDate(), dansLeMois: d.getMonth() === mois.getMonth() });
    }
    return jours;
  });

  libelleMois = computed(() =>
    this.moisCourant().toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
  );

  libelleJour = computed(() =>
    depuisIso(this.jourSelectionne()).toLocaleDateString('fr-FR', {
      weekday: 'long', day: 'numeric', month: 'long'
    })
  );

  parJour = computed(() => {
    const map = new Map<string, PatientDto[]>();
    for (const r of this.rdvs()) {
      if (!r.dateRdv) continue;
      if (!map.has(r.dateRdv)) map.set(r.dateRdv, []);
      map.get(r.dateRdv)!.push(r);
    }
    return map;
  });

  rdvsDuJour = computed(() => this.parJour().get(this.jourSelectionne()) ?? []);

  ngOnInit(): void {
    this.charger();
  }

  charger(): void {
    const jours = this.grille();
    this.chargement.set(true);
    this.erreur.set('');
    this.patientService.agenda(jours[0].date, jours[41].date).subscribe({
      next: (liste) => {
        this.rdvs.set(liste);
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set("Impossible de charger l'agenda.");
        this.chargement.set(false);
      }
    });
  }

  nombre(date: string): number {
    return this.parJour().get(date)?.length ?? 0;
  }

  choisir(date: string): void {
    this.jourSelectionne.set(date);
  }

  decalerMois(delta: number): void {
    const m = this.moisCourant();
    const nouveau = new Date(m.getFullYear(), m.getMonth() + delta, 1);
    this.moisCourant.set(nouveau);
    this.jourSelectionne.set(iso(nouveau));
    this.charger();
  }

  moisPrecedent(): void { this.decalerMois(-1); }
  moisSuivant(): void { this.decalerMois(1); }

  aujourdhui(): void {
    const now = new Date();
    this.moisCourant.set(new Date(now.getFullYear(), now.getMonth(), 1));
    this.jourSelectionne.set(iso(now));
    this.charger();
  }

  libelleStatut(statut: StatutRdv): string {
    return this.statuts.find((s) => s.valeur === statut)?.libelle ?? statut;
  }

  heure(r: PatientDto): string {
    return r.heureRdv ? r.heureRdv.substring(0, 5) : '—';
  }

  changerStatut(r: PatientDto, statut: string): void {
    const valeur = statut as StatutRdv;
    this.patientService.changerStatut(r.id, valeur).subscribe({
      next: () => this.rdvs.update((l) => l.map((x) => (x.id === r.id ? { ...x, statut: valeur } : x))),
      error: () => alert('Impossible de changer le statut.')
    });
  }

  basculerPaiement(r: PatientDto): void {
    const paye = !r.paye;
    this.patientService.changerPaiement(r.id, paye).subscribe({
      next: () => this.rdvs.update((l) => l.map((x) => (x.id === r.id ? { ...x, paye } : x))),
      error: () => alert('Impossible de changer le paiement.')
    });
  }

  ouvrir(r: PatientDto): void {
    this.router.navigate(['/patients', r.id]);
  }

  repeter(r: PatientDto): void {
    this.router.navigate(['/patients/nouveau'], {
      queryParams: { copie: r.id, date: this.jourSelectionne() }
    });
  }

  nouveau(): void {
    this.router.navigate(['/patients/nouveau'], { queryParams: { date: this.jourSelectionne() } });
  }
}