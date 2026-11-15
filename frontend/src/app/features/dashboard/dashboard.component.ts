import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { DashboardService } from '../../core/services/dashboard.service';
import { PendingCountService } from '../../core/services/pending-number.service';
import { RappelService } from '../../core/services/rappel.service';
import { Dashboard, STATUTS_RDV, StatutRdv } from '../../core/models/models';
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit, OnDestroy {
  pending = inject(PendingCountService);
  rappels = inject(RappelService);
  auth = inject(AuthService);
  private dashboardService = inject(DashboardService);
  private router = inject(Router);
  
  libelleStatut(statut: StatutRdv): string {
  return STATUTS_RDV.find((s) => s.valeur === statut)?.libelle ?? statut;
}
  data = signal<Dashboard | null>(null);
  chargement = signal(true);
  erreur = signal('');
  private timer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    if (this.auth.isMedecin()) this.pending.refresh();
    this.charger();
    this.timer = setInterval(() => this.charger(), 30000);
  }

  ngOnDestroy(): void {
    if (this.timer) clearInterval(this.timer);
  }

  private charger(): void {
  this.dashboardService.get().subscribe({
    next: (d) => {
      this.data.set({
        ...d,
        alertes: d.alertes ?? [],
        patientsEnAttentePaiement: d.patientsEnAttentePaiement ?? [],
        rdvDuJour: d.rdvDuJour ?? []
      });
      this.erreur.set('');
      this.chargement.set(false);
    },
    error: () => {
      if (!this.data()) this.erreur.set('Impossible de charger le tableau de bord.');
      this.chargement.set(false);
    }
  });
}

  voirProduit(produitId: string): void {
    this.router.navigate(['/produits', produitId]);
  }

  voirPatient(patientId: string): void {
    this.router.navigate(['/patients', patientId]);
  }

  heure(heureRdv?: string): string {
    return heureRdv ? heureRdv.substring(0, 5) : '—';
  }
}