package com.example.stock.supplier.dto;

import java.util.UUID;

public class SupplierDto {
    private final UUID id;
    private final String nom;
    private final String telephone;

    public SupplierDto(UUID id, String nom, String telephone) {
        this.id = id;
        this.nom = nom;
        this.telephone = telephone;
    }

    public UUID getId() { return id; }
    public String getNom() { return nom; }
    public String getTelephone() { return telephone; }
}