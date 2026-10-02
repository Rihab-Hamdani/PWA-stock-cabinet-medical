package com.example.stock.alert.entity;

import com.example.stock.shared.entity.BaseEntity;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "alerts")
public class Alert extends BaseEntity {

    @Column(name = "produit_id", nullable = false)
    private UUID produitId;

    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "alert_status", nullable = false)
    private AlertStatus statut = AlertStatus.ACTIVE;

    @Column(name = "date_derniere_notification")
    private Instant dateDerniereNotification;

    @Column(name = "date_commande")
    private Instant dateCommande;

    @Column(name = "commande_par")
    private UUID commandePar;

    @Column(name = "fournisseur_prevu_id")
    private UUID fournisseurPrevuId;

    @Column(name = "date_livraison_prevue")
    private LocalDate dateLivraisonPrevue;

    @Column(name = "date_resolution")
    private Instant dateResolution;

    public UUID getProduitId() { return produitId; }
    public void setProduitId(UUID produitId) { this.produitId = produitId; }
    public AlertStatus getStatut() { return statut; }
    public void setStatut(AlertStatus statut) { this.statut = statut; }
    public Instant getDateDerniereNotification() { return dateDerniereNotification; }
    public void setDateDerniereNotification(Instant d) { this.dateDerniereNotification = d; }
    public Instant getDateCommande() { return dateCommande; }
    public void setDateCommande(Instant dateCommande) { this.dateCommande = dateCommande; }
    public UUID getCommandePar() { return commandePar; }
    public void setCommandePar(UUID commandePar) { this.commandePar = commandePar; }
    public UUID getFournisseurPrevuId() { return fournisseurPrevuId; }
    public void setFournisseurPrevuId(UUID f) { this.fournisseurPrevuId = f; }
    public LocalDate getDateLivraisonPrevue() { return dateLivraisonPrevue; }
    public void setDateLivraisonPrevue(LocalDate d) { this.dateLivraisonPrevue = d; }
    public Instant getDateResolution() { return dateResolution; }
    public void setDateResolution(Instant dateResolution) { this.dateResolution = dateResolution; }
}