package com.example.stock.patient.dto;

import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.time.LocalDate;

public class PatientRequest {

    private String email;

    @NotBlank
    private String prenom;

    @NotBlank
    private String nom;

    private LocalDate dateNaissance;
    private String sexe;
    private String telephone;
    private String adresse;
    private String examenDemande;
    private String medecinTraitant;
    private String clinique;
    private LocalDate dateRdv;
    private String assurance;
    private BigDecimal montantPaye;
    private String remarques;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }
    public String getSexe() { return sexe; }
    public void setSexe(String sexe) { this.sexe = sexe; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getExamenDemande() { return examenDemande; }
    public void setExamenDemande(String examenDemande) { this.examenDemande = examenDemande; }
    public String getMedecinTraitant() { return medecinTraitant; }
    public void setMedecinTraitant(String medecinTraitant) { this.medecinTraitant = medecinTraitant; }
    public String getClinique() { return clinique; }
    public void setClinique(String clinique) { this.clinique = clinique; }
    public LocalDate getDateRdv() { return dateRdv; }
    public void setDateRdv(LocalDate dateRdv) { this.dateRdv = dateRdv; }
    public String getAssurance() { return assurance; }
    public void setAssurance(String assurance) { this.assurance = assurance; }
    public BigDecimal getMontantPaye() { return montantPaye; }
    public void setMontantPaye(BigDecimal montantPaye) { this.montantPaye = montantPaye; }
    public String getRemarques() { return remarques; }
    public void setRemarques(String remarques) { this.remarques = remarques; }
}