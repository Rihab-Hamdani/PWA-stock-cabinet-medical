import { Component, effect, inject } from '@angular/core';
import { Router } from '@angular/router';
import { NotificationService, Toast } from '../../../core/services/notification.service';

@Component({
  selector: 'app-notification-toast',
  standalone: true,
  template: `
    <div class="pile" aria-live="polite">
      @for (t of notifs.toasts(); track t.id) {
        <div class="toast" [attr.data-type]="t.type" role="status">
          <button type="button" class="corps" (click)="ouvrir(t)">
            <span class="titre">{{ t.titre }}</span>
            <span class="texte">{{ t.texte }}</span>
          </button>
          <button type="button" class="fermer" (click)="notifs.fermerToast(t.id)" aria-label="Fermer">×</button>
        </div>
      }
    </div>
  `,
  styleUrl: './notification-toast.component.scss'
})
export class NotificationToastComponent {
  notifs = inject(NotificationService);
  private router = inject(Router);
  private minuteurs = new Map<string, ReturnType<typeof setTimeout>>();

  constructor() {
    // Fermeture automatique : 15 s pour le stock, 60 s pour un rendez-vous.
    effect(() => {
      for (const t of this.notifs.toasts()) {
        if (this.minuteurs.has(t.id)) continue;
        const delai = t.type === 'rdv' ? 60_000 : 15_000;
        this.minuteurs.set(t.id, setTimeout(() => {
          this.notifs.fermerToast(t.id);
          this.minuteurs.delete(t.id);
        }, delai));
      }
    });
  }

  ouvrir(t: Toast): void {
    this.notifs.fermerToast(t.id);
    this.router.navigateByUrl(t.lien);
  }
}
