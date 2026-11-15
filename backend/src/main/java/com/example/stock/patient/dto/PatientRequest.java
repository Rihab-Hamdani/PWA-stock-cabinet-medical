package com.example.stock.patient.dto;

import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public record PatientRequest(
        String email,
        @NotBlank String prenom,
        @NotBlank String nom,
        LocalDate dateNaissance,
        String sexe,
        String telephone,
        String adresse,
        String examenDemande,
        String medecinTraitant,
        String clinique,
        LocalDate dateRdv,
        LocalTime heureRdv,
        String statut,
        boolean paye,
        String assurance,
        BigDecimal montantPaye,
        String remarques) {
}