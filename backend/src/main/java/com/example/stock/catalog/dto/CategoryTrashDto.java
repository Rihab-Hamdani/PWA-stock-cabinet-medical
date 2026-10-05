package com.example.stock.catalog.dto;

import java.time.Instant;
import java.util.UUID;

public class CategoryTrashDto {
    private final UUID id;
    private final String nom;
    private final Instant deletedAt;

    public CategoryTrashDto(UUID id, String nom, Instant deletedAt) {
        this.id = id;
        this.nom = nom;
        this.deletedAt = deletedAt;
    }

    public UUID getId() { return id; }
    public String getNom() { return nom; }
    public Instant getDeletedAt() { return deletedAt; }
}