package com.example.stock.patient.dto;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public record PatientDto(
        UUID id,
        String prenom,
        String nom,
        String telephone,
        String examenDemande,
        LocalDate dateRdv,
        LocalTime heureRdv,
        String statut,
        boolean paye) {
}