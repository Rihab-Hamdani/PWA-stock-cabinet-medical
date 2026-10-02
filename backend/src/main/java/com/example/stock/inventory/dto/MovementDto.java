package com.example.stock.inventory.dto;

import com.example.stock.inventory.entity.MovementType;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public class MovementDto {
    private final UUID id;
    private final MovementType type;
    private final int quantite;
    private final LocalDate dateMouvement;
    private final LocalTime heureMouvement;
    private final BigDecimal prixUnitaireHt;
    private final BigDecimal prixTotalHt;
    private final BigDecimal prixTotalTtc;
    private final String fournisseurNom;
    private final String numeroFacture;
    private final String motif;
    private final String utilisateurNom;

    public MovementDto(UUID id, MovementType type, int quantite, LocalDate dateMouvement, LocalTime heureMouvement,
                       BigDecimal prixUnitaireHt, BigDecimal prixTotalHt, BigDecimal prixTotalTtc,
                       String fournisseurNom, String numeroFacture, String motif, String utilisateurNom) {
        this.id = id;
        this.type = type;
        this.quantite = quantite;
        this.dateMouvement = dateMouvement;
        this.heureMouvement = heureMouvement;
        this.prixUnitaireHt = prixUnitaireHt;
        this.prixTotalHt = prixTotalHt;
        this.prixTotalTtc = prixTotalTtc;
        this.fournisseurNom = fournisseurNom;
        this.numeroFacture = numeroFacture;
        this.motif = motif;
        this.utilisateurNom = utilisateurNom;
    }

    public UUID getId() { return id; }
    public MovementType getType() { return type; }
    public int getQuantite() { return quantite; }
    public LocalDate getDateMouvement() { return dateMouvement; }
    public LocalTime getHeureMouvement() { return heureMouvement; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public BigDecimal getPrixTotalHt() { return prixTotalHt; }
    public BigDecimal getPrixTotalTtc() { return prixTotalTtc; }
    public String getFournisseurNom() { return fournisseurNom; }
    public String getNumeroFacture() { return numeroFacture; }
    public String getMotif() { return motif; }
    public String getUtilisateurNom() { return utilisateurNom; }
}