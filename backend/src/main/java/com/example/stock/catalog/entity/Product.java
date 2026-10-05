package com.example.stock.catalog.entity;

import com.example.stock.shared.entity.BaseEntity;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "products")
public class Product extends BaseEntity {

    @Column(nullable = false)
    private String nom;

    @Column(name = "categorie_id", nullable = false)
    private UUID categorieId;

    @Column(nullable = false)
    private String unite = "pièce";

    @Column(name = "quantite_actuelle", nullable = false)
    private int quantiteActuelle = 0;

    @Column(name = "seuil_alerte", nullable = false)
    private int seuilAlerte = 5;

    @Column(name = "prix_unitaire_ht")
    private BigDecimal prixUnitaireHt = BigDecimal.ZERO;

    @Column(name = "date_peremption")
    private LocalDate datePeremption;

    @Column(name = "numero_lot")
    private String numeroLot;

    @Column(nullable = false)
    private boolean actif = true;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public UUID getCategorieId() { return categorieId; }
    public void setCategorieId(UUID categorieId) { this.categorieId = categorieId; }
    public String getUnite() { return unite; }
    public void setUnite(String unite) { this.unite = unite; }
    public int getQuantiteActuelle() { return quantiteActuelle; }
    public void setQuantiteActuelle(int quantiteActuelle) { this.quantiteActuelle = quantiteActuelle; }
    public int getSeuilAlerte() { return seuilAlerte; }
    public void setSeuilAlerte(int seuilAlerte) { this.seuilAlerte = seuilAlerte; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public void setPrixUnitaireHt(BigDecimal prixUnitaireHt) { this.prixUnitaireHt = prixUnitaireHt; }
    public LocalDate getDatePeremption() { return datePeremption; }
    public void setDatePeremption(LocalDate datePeremption) { this.datePeremption = datePeremption; }
    public String getNumeroLot() { return numeroLot; }
    public void setNumeroLot(String numeroLot) { this.numeroLot = numeroLot; }
    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
    public Instant getDeletedAt() { return deletedAt; }
    public void setDeletedAt(Instant deletedAt) { this.deletedAt = deletedAt; }
}