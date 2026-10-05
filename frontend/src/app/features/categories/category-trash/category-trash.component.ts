import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CategoryService } from '../../../core/services/category.service';
import { ConfirmService } from '../../../core/services/confirrm.service';
import { CategoryTrash } from '../../../core/models/models';

@Component({
  selector: 'app-category-trash',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './category-trash.component.html',
  styleUrl: './category-trash.component.scss'
})
export class CategoryTrashComponent implements OnInit {
  private categoryService = inject(CategoryService);
  private confirmService = inject(ConfirmService);

  items = signal<CategoryTrash[]>([]);
  chargement = signal(true);
  enCours = signal<string | null>(null);

  ngOnInit(): void {
    this.charger();
  }

  charger(): void {
    this.chargement.set(true);
    this.categoryService.listTrash().subscribe({
      next: (liste) => { this.items.set(liste); this.chargement.set(false); },
      error: () => this.chargement.set(false)
    });
  }

  tempsRestant(deletedAt: string): string {
    const ms = new Date(deletedAt).getTime() + 24 * 3600 * 1000 - Date.now();
    if (ms <= 0) return 'Suppression imminente';
    const h = Math.floor(ms / 3600000);
    const m = Math.floor((ms % 3600000) / 60000);
    return `Suppression dans ${h} h ${m} min`;
  }

  async restaurer(item: CategoryTrash): Promise<void> {
    const ok = await this.confirmService.ask({
      titre: 'Restaurer la catégorie',
      message: `Restaurer "${item.nom}" avec ses produits ?`,
      texteConfirmer: 'Restaurer'
    });
    if (!ok) return;

    this.enCours.set(item.id);
    this.categoryService.restore(item.id).subscribe({
      next: () => { this.enCours.set(null); this.charger(); },
      error: (err) => {
        this.enCours.set(null);
        alert(err?.error?.message || 'Impossible de restaurer.');
      }
    });
  }

  async supprimerDefinitivement(item: CategoryTrash): Promise<void> {
    const ok = await this.confirmService.ask({
      titre: 'Supprimer définitivement ?',
      message: `"${item.nom}" et ses produits disparaîtront de l'application. L'historique des mouvements est conservé. Cette action est irréversible.`,
      texteConfirmer: 'Supprimer définitivement',
      danger: true
    });
    if (!ok) return;

    this.enCours.set(item.id);
    this.categoryService.deletePermanently(item.id).subscribe({
      next: () => { this.enCours.set(null); this.charger(); },
      error: (err) => {
        this.enCours.set(null);
        alert(err?.error?.message || 'Impossible de supprimer.');
      }
    });
  }
}