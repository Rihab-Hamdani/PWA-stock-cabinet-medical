package com.example.stock.supplier.dto;

import jakarta.validation.constraints.NotBlank;

public class SupplierRequest {

    @NotBlank
    private String nom;

    private String telephone;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
}