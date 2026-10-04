package com.example.stock.catalog.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class ProductRequest {

    @NotBlank
    private String nom;

    @NotNull
    private UUID categorieId;

    private String unite = "pièce";
    private int seuilAlerte = 5;
    private BigDecimal prixUnitaireHt = BigDecimal.ZERO;
    private LocalDate datePeremption;
    private String numeroLot;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public UUID getCategorieId() { return categorieId; }
    public void setCategorieId(UUID categorieId) { this.categorieId = categorieId; }
    public String getUnite() { return unite; }
    public void setUnite(String unite) { this.unite = unite; }
    public int getSeuilAlerte() { return seuilAlerte; }
    public void setSeuilAlerte(int seuilAlerte) { this.seuilAlerte = seuilAlerte; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public void setPrixUnitaireHt(BigDecimal prixUnitaireHt) { this.prixUnitaireHt = prixUnitaireHt; }
    public LocalDate getDatePeremption() { return datePeremption; }
    public void setDatePeremption(LocalDate datePeremption) { this.datePeremption = datePeremption; }
    public String getNumeroLot() { return numeroLot; }
    public void setNumeroLot(String numeroLot) { this.numeroLot = numeroLot; }
}