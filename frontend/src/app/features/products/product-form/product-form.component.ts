import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { CategoryService } from '../../../core/services/category.service';
import { ProductService } from '../../../core/services/product.service';
import { Category, Product } from '../../../core/models/models';

@Component({
  selector: 'app-product-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './product-form.component.html',
  styleUrl: './product-form.component.scss'
})
export class ProductFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private categoryService = inject(CategoryService);
  private productService = inject(ProductService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);


  categories = signal<Category[]>([]);
  chargement = signal(false);
  erreur = signal('');
  produitId = signal<string | null>(null);

  form = this.fb.nonNullable.group({
    nom: ['', Validators.required],
    categorieId: ['', Validators.required],
    unite: ['pièce', Validators.required],
    seuilAlerte: [5, [Validators.required, Validators.min(0)]],
    prixUnitaireHt: [0, [Validators.required, Validators.min(0)]],
    datePeremption: [''],
    numeroLot: ['']
  });

  ngOnInit(): void {
    this.categoryService.list().subscribe((cats) => this.categories.set(cats));

    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.produitId.set(id);
      const produit = history.state?.produit as Product | undefined;
      if (produit) {
        this.form.patchValue({
          nom: produit.nom,
          categorieId: produit.categorieId,
          unite: produit.unite,
          seuilAlerte: produit.seuilAlerte,
          prixUnitaireHt: produit.prixUnitaireHt,
          datePeremption: produit.datePeremption ?? '',
          numeroLot: produit.numeroLot ?? ''
        });
      }
    }
  }

  

  submit(): void {
  if (this.form.invalid) return;
  this.chargement.set(true);
  this.erreur.set('');

  const valeurs = this.form.getRawValue();
  const payload = {
    ...valeurs,
    datePeremption: valeurs.datePeremption || null,
    numeroLot: valeurs.numeroLot || null
  };

  const id = this.produitId();

  if (id) {
    this.productService.update(id, payload).subscribe({
      next: () => this.router.navigate(['/produits']),
      error: () => {
        this.chargement.set(false);
        this.erreur.set("Impossible d'enregistrer le produit.");
      }
    });
  } else {
    this.productService.create(payload).subscribe({
      next: () => this.router.navigate(['/produits']),
      error: () => {
        this.chargement.set(false);
        this.erreur.set("Impossible d'enregistrer le produit.");
      }
    });
  }
}
}