import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ProductService } from '../../../core/services/product.service';
import { SupplierService } from '../../../core/services/supplier.service';
import { MovementService } from '../../../core/services/movement.service';
import { Product, Supplier, MovementHistorique } from '../../../core/models/models';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  imports: [RouterLink, ReactiveFormsModule],
  templateUrl: './product-detail.component.html',
  styleUrl: './product-detail.component.scss'
})
export class ProductDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private productService = inject(ProductService);
  private supplierService = inject(SupplierService);
  private movementService = inject(MovementService);
  private fb = inject(FormBuilder);

  produit = signal<Product | null>(null);
  fournisseurs = signal<Supplier[]>([]);
  historique = signal<MovementHistorique[]>([]);
  chargementHistorique = signal(true);

  panneauArrivage = signal(false);
  enCoursUtiliser = signal(false);
  chargementArrivage = signal(false);
  erreurArrivage = signal('');
  modeFournisseur = signal<'liste' | 'nouveau'>('liste');

  formArrivage = this.fb.nonNullable.group({
    quantite: [1, [Validators.required, Validators.min(1)]],
    prixUnitaireHt: [0, [Validators.required, Validators.min(0)]],
    fournisseurId: [''],
    fournisseurNom: [''],
    fournisseurTelephone: [''],
    numeroFacture: ['']
  });

  ngOnInit(): void {
    const produit = history.state?.produit as Product | undefined;
    if (produit) this.produit.set(produit);

    this.supplierService.list().subscribe((f) => this.fournisseurs.set(f));

    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.productService.list().subscribe((liste) => {
        const trouve = liste.find((p) => p.id === id);
        if (trouve) this.produit.set(trouve);
      });
      this.chargerHistorique(id);
    }
  }

  chargerHistorique(id: string): void {
    this.chargementHistorique.set(true);
    this.movementService.historiqueProduit(id).subscribe({
      next: (h) => {
        this.historique.set(h);
        this.chargementHistorique.set(false);
      },
      error: () => this.chargementHistorique.set(false)
    });
  }

  utiliser(): void {
    const p = this.produit();
    if (!p || p.quantiteActuelle === 0) return;

    this.enCoursUtiliser.set(true);
    this.productService.sortieRapide(p.id).subscribe({
      next: () => {
        this.produit.update((prod) => prod ? { ...prod, quantiteActuelle: prod.quantiteActuelle - 1 } : prod);
        this.enCoursUtiliser.set(false);
        this.chargerHistorique(p.id);
      },
      error: () => this.enCoursUtiliser.set(false)
    });
  }

  validerArrivage(): void {
    const p = this.produit();
    if (!p || this.formArrivage.invalid) return;

    this.chargementArrivage.set(true);
    this.erreurArrivage.set('');

    const valeurs = this.formArrivage.getRawValue();
    const payload = this.modeFournisseur() === 'liste'
      ? { quantite: valeurs.quantite, prixUnitaireHt: valeurs.prixUnitaireHt, fournisseurId: valeurs.fournisseurId || null, numeroFacture: valeurs.numeroFacture || null }
      : { quantite: valeurs.quantite, prixUnitaireHt: valeurs.prixUnitaireHt, fournisseurNom: valeurs.fournisseurNom || null, fournisseurTelephone: valeurs.fournisseurTelephone || null, numeroFacture: valeurs.numeroFacture || null };

    this.productService.enregistrerArrivage(p.id, payload).subscribe({
      next: () => {
        this.produit.update((prod) => prod ? { ...prod, quantiteActuelle: prod.quantiteActuelle + valeurs.quantite } : prod);
        this.chargementArrivage.set(false);
        this.panneauArrivage.set(false);
        this.formArrivage.reset({ quantite: 1, prixUnitaireHt: 0, fournisseurId: '', fournisseurNom: '', fournisseurTelephone: '', numeroFacture: '' });
        this.supplierService.list().subscribe((f) => this.fournisseurs.set(f));
        this.chargerHistorique(p.id);
      },
      error: () => {
        this.chargementArrivage.set(false);
        this.erreurArrivage.set("Impossible d'enregistrer l'arrivage.");
      }
    });
  }

  modifier(): void {
    const p = this.produit();
    if (p) this.router.navigate(['/produits', p.id, 'modifier'], { state: { produit: p } });
  }

  desactiver(): void {
    const p = this.produit();
    if (!p || !confirm(`Désactiver "${p.nom}" ?`)) return;
    this.productService.deactivate(p.id).subscribe({
      next: () => this.router.navigate(['/produits'])
    });
  }
}