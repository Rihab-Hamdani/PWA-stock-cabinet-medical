package com.example.stock.inventory.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

public class MovementEntreeRequest {

    @NotNull @Min(1)
    private Integer quantite;

    @NotNull @DecimalMin("0")
    private BigDecimal prixUnitaireHt;

    private UUID fournisseurId;
    private String fournisseurNom;
    private String fournisseurTelephone;
    private String numeroFacture;

    public Integer getQuantite() { return quantite; }
    public void setQuantite(Integer quantite) { this.quantite = quantite; }
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