package com.example.stock.shared.dto;

import com.example.stock.catalog.dto.ProductDto;

import java.math.BigDecimal;
import java.util.List;

public class DashboardDto {
    private final long produitsEnRupture;
    private final long produitsSousLeSeuil;
    private final long mouvementsAujourdHui;
    private final BigDecimal montantDuJour;
    private final BigDecimal montantPerdu;
    private final BigDecimal valeurDuStock;
    private final List<ProductDto> alertes;

    public DashboardDto(long produitsEnRupture, long produitsSousLeSeuil, long mouvementsAujourdHui,
                        BigDecimal montantDuJour, BigDecimal montantPerdu, BigDecimal valeurDuStock,
                        List<ProductDto> alertes) {
        this.produitsEnRupture = produitsEnRupture;
        this.produitsSousLeSeuil = produitsSousLeSeuil;
        this.mouvementsAujourdHui = mouvementsAujourdHui;
        this.montantDuJour = montantDuJour;
        this.montantPerdu = montantPerdu;
        this.valeurDuStock = valeurDuStock;
        this.alertes = alertes;
    }

    public long getProduitsEnRupture() { return produitsEnRupture; }
    public long getProduitsSousLeSeuil() { return produitsSousLeSeuil; }
    public long getMouvementsAujourdHui() { return mouvementsAujourdHui; }
    public BigDecimal getMontantDuJour() { return montantDuJour; }
    public BigDecimal getMontantPerdu() { return montantPerdu; }
    public BigDecimal getValeurDuStock() { return valeurDuStock; }
    public List<ProductDto> getAlertes() { return alertes; }
}