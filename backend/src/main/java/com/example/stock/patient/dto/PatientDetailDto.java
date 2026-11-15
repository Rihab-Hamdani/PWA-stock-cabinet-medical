package com.example.stock.patient.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public record PatientDetailDto(
        UUID id,
        String email,
        String prenom,
        String nom,
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