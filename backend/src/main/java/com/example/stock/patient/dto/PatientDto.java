package com.example.stock.patient.dto;

import java.time.LocalDate;
import java.util.UUID;

public class PatientDto {
    private final UUID id;
    private final String prenom;
    private final String nom;
    private final String telephone;
    private final String examenDemande;
    private final LocalDate dateRdv;

    public PatientDto(UUID id, String prenom, String nom, String telephone, String examenDemande, LocalDate dateRdv) {
        this.id = id;
        this.prenom = prenom;
        this.nom = nom;
        this.telephone = telephone;
        this.examenDemande = examenDemande;
        this.dateRdv = dateRdv;
    }

    public UUID getId() { return id; }
    public String getPrenom() { return prenom; }
    public String getNom() { return nom; }
    public String getTelephone() { return telephone; }
    public String getExamenDemande() { return examenDemande; }
    public LocalDate getDateRdv() { return dateRdv; }
}