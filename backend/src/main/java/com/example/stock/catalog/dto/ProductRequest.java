package com.example.stock.catalog.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Setter
@Getter
public class ProductRequest {

    @NotBlank
    private String nom;

    @NotNull
    private UUID categorieId;

    private String unite = "pièce";
    private int seuilAlerte = 5;
    private BigDecimal prixUnitaireHt = BigDecimal.ZERO;
    private LocalDate datePeremption;
    private String numeroLot;

}