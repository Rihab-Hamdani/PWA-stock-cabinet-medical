package com.example.stock.catalog.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class ProductDto {
    private final UUID id;
    private final String nom;
    private final UUID categorieId;
    private final String categorieNom;
    private final String unite;
    private final int quantiteActuelle;
    private final int seuilAlerte;
    private final BigDecimal prixUnitaireHt;
    private final LocalDate datePeremption;
    private final String numeroLot;
    private final boolean enRupture;

    public ProductDto(UUID id, String nom, UUID categorieId, String categorieNom, String unite,
                      int quantiteActuelle, int seuilAlerte, BigDecimal prixUnitaireHt,
                      LocalDate datePeremption, String numeroLot) {
        this.id = id;
        this.nom = nom;
        this.categorieId = categorieId;
        this.categorieNom = categorieNom;
        this.unite = unite;
        this.quantiteActuelle = quantiteActuelle;
        this.seuilAlerte = seuilAlerte;
        this.prixUnitaireHt = prixUnitaireHt;
        this.datePeremption = datePeremption;
        this.numeroLot = numeroLot;
        this.enRupture = quantiteActuelle <= seuilAlerte;
    }

    public UUID getId() { return id; }
    public String getNom() { return nom; }
    public UUID getCategorieId() { return categorieId; }
    public String getCategorieNom() { return categorieNom; }
    public String getUnite() { return unite; }
    public int getQuantiteActuelle() { return quantiteActuelle; }
    public int getSeuilAlerte() { return seuilAlerte; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public LocalDate getDatePeremption() { return datePeremption; }
    public String getNumeroLot() { return numeroLot; }
    public boolean isEnRupture() { return enRupture; }
}