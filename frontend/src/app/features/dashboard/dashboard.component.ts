import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { DashboardService } from '../../core/services/dashboard.service';
import { Dashboard } from '../../core/models/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit {
  auth = inject(AuthService);
  private dashboardService = inject(DashboardService);
  private router = inject(Router);

  data = signal<Dashboard | null>(null);
  chargement = signal(true);
  erreur = signal('');

  ngOnInit(): void {
    this.dashboardService.get().subscribe({
      next: (d) => {
        this.data.set(d);
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set('Impossible de charger le tableau de bord.');
        this.chargement.set(false);
      }
    });
  }

  voirProduit(produitId: string): void {
    this.router.navigate(['/produits', produitId]);
  }
}