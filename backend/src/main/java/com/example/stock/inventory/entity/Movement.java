package com.example.stock.inventory.entity;

import com.example.stock.shared.entity.BaseEntity;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "movements")
public class Movement extends BaseEntity {

    @Column(name = "produit_id", nullable = false)
    private UUID produitId;

    @Column(name = "utilisateur_id", nullable = false)
    private UUID utilisateurId;

    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "type", columnDefinition = "movement_type", nullable = false)
    private MovementType type;

    @Column(nullable = false)
    private int quantite;

    @Column(name = "date_mouvement", nullable = false)
    private LocalDate dateMouvement = LocalDate.now();

    @Column(name = "heure_mouvement", nullable = false)
    private LocalTime heureMouvement = LocalTime.now();

    @Column(name = "prix_unitaire_ht")
    private BigDecimal prixUnitaireHt;

    private BigDecimal tva;

    @Column(name = "prix_unitaire_ttc")
    private BigDecimal prixUnitaireTtc;

    @Column(name = "prix_total_ht")
    private BigDecimal prixTotalHt;

    @Column(name = "prix_total_ttc")
    private BigDecimal prixTotalTtc;

    @Column(name = "fournisseur_id")
    private UUID fournisseurId;

    @Column(name = "numero_facture")
    private String numeroFacture;

    private String motif;

    public UUID getProduitId() { return produitId; }
    public void setProduitId(UUID produitId) { this.produitId = produitId; }
    public UUID getUtilisateurId() { return utilisateurId; }
    public void setUtilisateurId(UUID utilisateurId) { this.utilisateurId = utilisateurId; }
    public MovementType getType() { return type; }
    public void setType(MovementType type) { this.type = type; }
    public int getQuantite() { return quantite; }
    public void setQuantite(int quantite) { this.quantite = quantite; }
    public LocalDate getDateMouvement() { return dateMouvement; }
    public void setDateMouvement(LocalDate dateMouvement) { this.dateMouvement = dateMouvement; }
    public LocalTime getHeureMouvement() { return heureMouvement; }
    public void setHeureMouvement(LocalTime heureMouvement) { this.heureMouvement = heureMouvement; }
    public BigDecimal getPrixUnitaireHt() { return prixUnitaireHt; }
    public void setPrixUnitaireHt(BigDecimal prixUnitaireHt) { this.prixUnitaireHt = prixUnitaireHt; }
    public BigDecimal getTva() { return tva; }
    public void setTva(BigDecimal tva) { this.tva = tva; }
    public BigDecimal getPrixUnitaireTtc() { return prixUnitaireTtc; }
    public void setPrixUnitaireTtc(BigDecimal prixUnitaireTtc) { this.prixUnitaireTtc = prixUnitaireTtc; }
    public BigDecimal getPrixTotalHt() { return prixTotalHt; }
    public void setPrixTotalHt(BigDecimal prixTotalHt) { this.prixTotalHt = prixTotalHt; }
    public BigDecimal getPrixTotalTtc() { return prixTotalTtc; }
    public void setPrixTotalTtc(BigDecimal prixTotalTtc) { this.prixTotalTtc = prixTotalTtc; }
    public UUID getFournisseurId() { return fournisseurId; }
    public void setFournisseurId(UUID fournisseurId) { this.fournisseurId = fournisseurId; }
    public String getNumeroFacture() { return numeroFacture; }
    public void setNumeroFacture(String numeroFacture) { this.numeroFacture = numeroFacture; }
    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }
}