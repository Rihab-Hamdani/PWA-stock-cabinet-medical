package com.example.stock.catalog.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public class CategoryRequest {

    @NotBlank
    private String nom;

    @NotBlank
    private String produitNom;

    private String unite = "pièce";

    @Min(0)
    private int seuilAlerte = 5;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getProduitNom() { return produitNom; }
    public void setProduitNom(String produitNom) { this.produitNom = produitNom; }
    public String getUnite() { return unite; }
    public void setUnite(String unite) { this.unite = unite; }
    public int getSeuilAlerte() { return seuilAlerte; }
    public void setSeuilAlerte(int seuilAlerte) { this.seuilAlerte = seuilAlerte; }
}