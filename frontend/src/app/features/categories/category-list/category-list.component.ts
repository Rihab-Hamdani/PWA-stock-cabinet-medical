import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CategoryService } from '../../../core/services/category.service';
import { ProductService } from '../../../core/services/product.service';
import { SupplierService } from '../../../core/services/supplier.service';
import { Category, Product, Supplier } from '../../../core/models/models';

@Component({
  selector: 'app-category-list',
  standalone: true,
  imports: [FormsModule, ReactiveFormsModule],
  templateUrl: './category-list.component.html',
  styleUrl: './category-list.component.scss'
})
export class CategoryListComponent implements OnInit {
  private fb = inject(FormBuilder);
  private categoryService = inject(CategoryService);
  private productService = inject(ProductService);
  private supplierService = inject(SupplierService);
  private router = inject(Router);

  categories = signal<Category[]>([]);
  chargement = signal(true);
  erreur = signal('');
  recherche = signal('');

  categorieOuverte = signal<string | null>(null);
  produitsParCategorie = signal<Record<string, Product[]>>({});
  chargementProduits = signal<string | null>(null);
  enCoursUtiliser = signal<string | null>(null);
  enCoursSuppression = signal<string | null>(null);

  unites = signal<string[]>([]);
  fournisseurs = signal<Supplier[]>([]);

  // Formulaire "nouvelle catégorie"
  formulaireCategorieOuvert = signal(false);
  ajoutCategorieErreur = signal('');
  ajoutCategorieEnCours = signal(false);

  formCategorie = this.fb.nonNullable.group({
    nom: ['', Validators.required],
    produitNom: ['', Validators.required],
    unite: ['pièce', Validators.required],
    seuilAlerte: [5, [Validators.required, Validators.min(0)]]
  });

  // Formulaire "ajouter un produit" (dans une catégorie ouverte)
  categorieProduitCible = signal<string | null>(null);
  ajoutProduitEnCours = signal(false);
  ajoutProduitErreur = signal('');
  modeFournisseurProduit = signal<'liste' | 'nouveau'>('liste');

  formNouveauProduit = this.fb.nonNullable.group({
    nom: ['', Validators.required],
    unite: ['pièce', Validators.required],
    seuilAlerte: [5, [Validators.required, Validators.min(0)]],
    quantiteInitiale: [0, [Validators.required, Validators.min(0)]],
    prixUnitaireHt: [0, [Validators.required, Validators.min(0)]],
    fournisseurId: [''],
    fournisseurNom: [''],
    fournisseurTelephone: [''],
    numeroFacture: ['']
  });

  ngOnInit(): void {
    this.charger();
    this.productService.getUnites().subscribe((u) => this.unites.set(u));
    this.supplierService.list().subscribe((f) => this.fournisseurs.set(f));
  }

  charger(): void {
    this.chargement.set(true);
    this.erreur.set('');
    this.categoryService.list(this.recherche() || undefined).subscribe({
      next: (cats) => {
        this.categories.set(cats);
        this.chargement.set(false);
      },
      error: () => {
        this.erreur.set('Impossible de charger les catégories.');
        this.chargement.set(false);
      }
    });
  }

  onRechercheChange(valeur: string): void {
    this.recherche.set(valeur);
    this.charger();
  }

  produitsDe(id: string): Product[] {
    return this.produitsParCategorie()[id] || [];
  }

  toggleCategorie(id: string): void {
    if (this.categorieOuverte() === id) {
      this.categorieOuverte.set(null);
      return;
    }
    this.categorieOuverte.set(id);
    this.chargerProduitsDe(id);
  }

  chargerProduitsDe(id: string): void {
    this.chargementProduits.set(id);
    this.productService.list(id).subscribe({
      next: (produits) => {
        this.produitsParCategorie.update((map) => ({ ...map, [id]: produits }));
        this.chargementProduits.set(null);
      },
      error: () => this.chargementProduits.set(null)
    });
  }

  utiliser(produit: Product): void {
    if (produit.quantiteActuelle === 0) return;
    this.enCoursUtiliser.set(produit.id);
    this.productService.sortieRapide(produit.id).subscribe({
      next: () => {
        this.enCoursUtiliser.set(null);
        this.chargerProduitsDe(produit.categorieId);
      },
      error: () => this.enCoursUtiliser.set(null)
    });
  }

  voirDetail(produit: Product): void {
    this.router.navigate(['/produits', produit.id], { state: { produit } });
  }

  modifier(produit: Product): void {
    this.router.navigate(['/produits', produit.id, 'modifier'], { state: { produit } });
  }

  desactiver(produit: Product): void {
    if (!confirm(`Désactiver "${produit.nom}" ?`)) return;
    this.productService.deactivate(produit.id).subscribe({
      next: () => this.chargerProduitsDe(produit.categorieId)
    });
  }

  // ---- Nouvelle catégorie ----

  ajouterCategorie(): void {
    if (this.formCategorie.invalid) return;

    this.ajoutCategorieEnCours.set(true);
    this.ajoutCategorieErreur.set('');

    this.categoryService.create(this.formCategorie.getRawValue()).subscribe({
      next: () => {
        this.ajoutCategorieEnCours.set(false);
        this.formulaireCategorieOuvert.set(false);
        this.formCategorie.reset({ nom: '', produitNom: '', unite: 'pièce', seuilAlerte: 5 });
        this.charger();
      },
      error: (err) => {
        this.ajoutCategorieEnCours.set(false);
        this.ajoutCategorieErreur.set(
          err?.status === 409 ? 'Cette catégorie existe déjà.' : "Impossible d'ajouter la catégorie."
        );
      }
    });
  }

  supprimerCategorie(cat: Category, event: Event): void {
    event.stopPropagation();
    if (!confirm(`Supprimer la catégorie "${cat.nom}" ?`)) return;

    this.enCoursSuppression.set(cat.id);
    this.categoryService.delete(cat.id).subscribe({
      next: () => {
        this.enCoursSuppression.set(null);
        this.charger();
      },
      error: (err) => {
        this.enCoursSuppression.set(null);
        alert(err?.error?.message || 'Impossible de supprimer cette catégorie.');
      }
    });
  }

  // ---- Ajouter un produit à une catégorie existante ----

  ouvrirAjoutProduit(categorieId: string, event: Event): void {
    event.stopPropagation();
    this.categorieProduitCible.set(categorieId);
    this.ajoutProduitErreur.set('');
    this.formNouveauProduit.reset({
      nom: '', unite: 'pièce', seuilAlerte: 5, quantiteInitiale: 0, prixUnitaireHt: 0,
      fournisseurId: '', fournisseurNom: '', fournisseurTelephone: '', numeroFacture: ''
    });
  }

  fermerAjoutProduit(): void {
    this.categorieProduitCible.set(null);
  }

  ajouterProduit(): void {
    const categorieId = this.categorieProduitCible();
    if (!categorieId || this.formNouveauProduit.invalid) return;

    this.ajoutProduitEnCours.set(true);
    this.ajoutProduitErreur.set('');

    const v = this.formNouveauProduit.getRawValue();

    this.productService.create({
      nom: v.nom,
      categorieId,
      unite: v.unite,
      seuilAlerte: v.seuilAlerte,
      prixUnitaireHt: 0
    }).subscribe({
      next: (res) => {
        if (v.quantiteInitiale > 0) {
          const payload = this.modeFournisseurProduit() === 'liste'
            ? { quantite: v.quantiteInitiale, prixUnitaireHt: v.prixUnitaireHt, fournisseurId: v.fournisseurId || null, numeroFacture: v.numeroFacture || null }
            : { quantite: v.quantiteInitiale, prixUnitaireHt: v.prixUnitaireHt, fournisseurNom: v.fournisseurNom || null, fournisseurTelephone: v.fournisseurTelephone || null, numeroFacture: v.numeroFacture || null };

          this.productService.enregistrerArrivage(res.id, payload).subscribe({
            next: () => this.finaliserAjoutProduit(categorieId),
            error: () => this.finaliserAjoutProduit(categorieId)
          });
        } else {
          this.finaliserAjoutProduit(categorieId);
        }
      },
      error: () => {
        this.ajoutProduitEnCours.set(false);
        this.ajoutProduitErreur.set("Impossible de créer le produit.");
      }
    });
  }

  private finaliserAjoutProduit(categorieId: string): void {
    this.ajoutProduitEnCours.set(false);
    this.categorieProduitCible.set(null);
    this.supplierService.list().subscribe((f) => this.fournisseurs.set(f));
    this.chargerProduitsDe(categorieId);
  }
}