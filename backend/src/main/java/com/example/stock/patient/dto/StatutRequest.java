package com.example.stock.patient.dto;

import jakarta.validation.constraints.NotBlank;

public record StatutRequest(@NotBlank String statut) {
}