package com.example.stock.catalog.dto;

import java.util.UUID;

public class CreatedResponse {
    private final UUID id;

    public CreatedResponse(UUID id) {
        this.id = id;
    }

    public UUID getId() { return id; }
}