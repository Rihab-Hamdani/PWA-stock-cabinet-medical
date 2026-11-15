package com.example.stock.catalog.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.util.UUID;

public class CategoryRequest {

    @NotBlank
    private String nom;

    @NotBlank
    private String produitNom;

    private String unite = "pièce";

    @Min(0)
    private int seuilAlerte = 5;

    @Min(0)
    private int quantiteInitiale = 0;

    @DecimalMin("0")
    private BigDecimal prixUnitaireHt = BigDecimal.ZERO;

    private UUID fournisseurId;
    private String fournisseurNom;
    private String fournisseurTelephone;
    private String numeroFacture;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getProduitNom() { return produitNom; }
    public void setProduitNom(String produitNom) { this.produitNom = produitNom; }
    public String getUnite() { return unite; }
    public void setUnite(String unite) { this.unite = unite; }
    public int getSeuilAlerte() { return seuilAlerte; }
    public void setSeuilAlerte(int seuilAlerte) { this.seuilAlerte = seuilAlerte; }
    public int getQuantiteInitiale() { return quantiteInitiale; }
    public void setQuantiteInitiale(int quantiteInitiale) { this.quantiteInitiale = quantiteInitiale; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public void setPrixUnitaireHt(BigDecimal prixUnitaireHt) { this.prixUnitaireHt = prixUnitaireHt; }
    public UUID getFournisseurId() { return fournisseurId; }
    public void setFournisseurId(UUID fournisseurId) { this.fournisseurId = fournisseurId; }
    public String getFournisseurNom() { return fournisseurNom; }
    public void setFournisseurNom(String fournisseurNom) { this.fournisseurNom = fournisseurNom; }
    public String getFournisseurTelephone() { return fournisseurTelephone; }
    public void setFournisseurTelephone(String fournisseurTelephone) { this.fournisseurTelephone = fournisseurTelephone; }
    public String getNumeroFacture() { return numeroFacture; }
    public void setNumeroFacture(String numeroFacture) { this.numeroFacture = numeroFacture; }
}