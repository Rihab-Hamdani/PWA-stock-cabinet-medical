package com.example.stock.catalog.dto;

import java.util.UUID;

public class CategoryDto {
    private final UUID id;
    private final String nom;

    public CategoryDto(UUID id, String nom) {
        this.id = id;
        this.nom = nom;
    }

    public UUID getId() { return id; }
    public String getNom() { return nom; }
}