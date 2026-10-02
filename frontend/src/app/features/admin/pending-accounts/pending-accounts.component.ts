import { Component, OnInit, inject, signal } from '@angular/core';
import { UserService } from '../../../core/services/user.service';
import { User } from '../../../core/models/models';

@Component({
  selector: 'app-pending-accounts',
  standalone: true,
  templateUrl: './pending-accounts.component.html',
  styleUrl: './pending-accounts.component.scss'
})
export class PendingAccountsComponent implements OnInit {
  private userService = inject(UserService);

  comptes = signal<User[]>([]);
  chargement = signal(true);
  erreur = signal('');
  enCours = signal<string | null>(null);

  ngOnInit(): void {
    this.charger();
  }

  charger(): void {
    this.chargement.set(true);
    this.userService.pending().subscribe({
      next: (comptes) => {
        this.comptes.set(comptes);
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set("Impossible de charger les comptes en attente.");
        this.chargement.set(false);
      }
    });
  }

  activer(id: string): void {
    this.enCours.set(id);
    this.userService.activate(id).subscribe({
      next: () => {
        this.comptes.update((liste) => liste.filter((c) => c.id !== id));
        this.enCours.set(null);
      },
      error: () => this.enCours.set(null)
    });
  }

  rejeter(id: string): void {
    if (!confirm('Supprimer définitivement cette demande de compte ?')) return;
    this.enCours.set(id);
    this.userService.reject(id).subscribe({
      next: () => {
        this.comptes.update((liste) => liste.filter((c) => c.id !== id));
        this.enCours.set(null);
      },
      error: () => this.enCours.set(null)
    });
  }
}