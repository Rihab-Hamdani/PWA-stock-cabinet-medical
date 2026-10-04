package com.example.stock.patient.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class PatientDetailDto {
    private final UUID id;
    private final String email;
    private final String prenom;
    private final String nom;
    private final LocalDate dateNaissance;
    private final String sexe;
    private final String telephone;
    private final String adresse;
    private final String examenDemande;
    private final String medecinTraitant;
    private final String clinique;
    private final LocalDate dateRdv;
    private final String assurance;
    private final BigDecimal montantPaye;
    private final String remarques;

    public PatientDetailDto(UUID id, String email, String prenom, String nom, LocalDate dateNaissance,
                            String sexe, String telephone, String adresse, String examenDemande,
                            String medecinTraitant, String clinique, LocalDate dateRdv,
                            String assurance, BigDecimal montantPaye, String remarques) {
        this.id = id;
        this.email = email;
        this.prenom = prenom;
        this.nom = nom;
        this.dateNaissance = dateNaissance;
        this.sexe = sexe;
        this.telephone = telephone;
        this.adresse = adresse;
        this.examenDemande = examenDemande;
        this.medecinTraitant = medecinTraitant;
        this.clinique = clinique;
        this.dateRdv = dateRdv;
        this.assurance = assurance;
        this.montantPaye = montantPaye;
        this.remarques = remarques;
    }

    public UUID getId() { return id; }
    public String getEmail() { return email; }
    public String getPrenom() { return prenom; }
    public String getNom() { return nom; }
    public LocalDate getDateNaissance() { return dateNaissance; }
    public String getSexe() { return sexe; }
    public String getTelephone() { return telephone; }
    public String getAdresse() { return adresse; }
    public String getExamenDemande() { return examenDemande; }
    public String getMedecinTraitant() { return medecinTraitant; }
    public String getClinique() { return clinique; }
    public LocalDate getDateRdv() { return dateRdv; }
    public String getAssurance() { return assurance; }
    public BigDecimal getMontantPaye() { return montantPaye; }
    public String getRemarques() { return remarques; }
}