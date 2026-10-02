import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CategoryService } from '../../../core/services/category.service';
import { ProductService } from '../../../core/services/product.service';
import { Category, Product } from '../../../core/models/models';
import { HasRoleDirective } from '../../../shared/directives/has-role.directive';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule, HasRoleDirective],
  templateUrl: './product-list.component.html',
  styleUrl: './product-list.component.scss'
})
export class ProductListComponent implements OnInit {
  private categoryService = inject(CategoryService);
  private productService = inject(ProductService);
  private router = inject(Router);

  categories = signal<Category[]>([]);
  produits = signal<Product[]>([]);
  chargement = signal(true);
  erreur = signal('');
  enCoursSortie = signal<string | null>(null);

  categorieActive = signal<string | null>(null);
  recherche = signal('');

  ngOnInit(): void {
    this.categoryService.list().subscribe((cats) => this.categories.set(cats));
    this.charger();
  }

  voirDetail(produit: Product): void {
  this.router.navigate(['/produits', produit.id], { state: { produit } });
}

  charger(): void {
    this.chargement.set(true);
    this.erreur.set('');
    this.productService.list(this.categorieActive() ?? undefined, this.recherche() || undefined).subscribe({
      next: (produits) => {
        this.produits.set(produits);
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set('Impossible de charger les produits.');
        this.chargement.set(false);
      }
    });
  }

  filtrerParCategorie(id: string | null): void {
    this.categorieActive.set(id);
    this.charger();
  }

  onRechercheChange(valeur: string): void {
    this.recherche.set(valeur);
    this.charger();
  }

  modifier(produit: Product): void {
    this.router.navigate(['/produits', produit.id, 'modifier'], { state: { produit } });
  }

  desactiver(produit: Product): void {
    if (!confirm(`Désactiver "${produit.nom}" ?`)) return;
    this.productService.deactivate(produit.id).subscribe({ next: () => this.charger() });
  }
  utiliser(produit: Product): void {
  this.enCoursSortie.set(produit.id);
  this.productService.sortieRapide(produit.id).subscribe({
    next: () => {
      this.enCoursSortie.set(null);
      this.charger();
    },
    error: () => this.enCoursSortie.set(null)
  });
}
}