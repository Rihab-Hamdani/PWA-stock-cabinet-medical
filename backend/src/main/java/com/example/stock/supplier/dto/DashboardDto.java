package com.example.stock.shared.dto;

import com.example.stock.catalog.dto.ProductDto;
import com.example.stock.patient.dto.PatientDto;

import java.math.BigDecimal;
import java.util.List;

public class DashboardDto {
    private final long produitsEnRupture;
    private final long produitsSousLeSeuil;
    private final long mouvementsAujourdHui;
    private final BigDecimal depensesStockDuJour;
    private final BigDecimal recettesPatientsDuJour;
    private final List<ProductDto> alertes;
    private final List<PatientDto> patientsEnAttentePaiement;
    private final List<PatientDto> rdvDuJour;

    public DashboardDto(long produitsEnRupture, long produitsSousLeSeuil, long mouvementsAujourdHui,
                        BigDecimal depensesStockDuJour, BigDecimal recettesPatientsDuJour,
                        List<ProductDto> alertes, List<PatientDto> patientsEnAttentePaiement,
                        List<PatientDto> rdvDuJour) {
        this.produitsEnRupture = produitsEnRupture;
        this.produitsSousLeSeuil = produitsSousLeSeuil;
        this.mouvementsAujourdHui = mouvementsAujourdHui;
        this.depensesStockDuJour = depensesStockDuJour;
        this.recettesPatientsDuJour = recettesPatientsDuJour;
        this.alertes = alertes;
        this.patientsEnAttentePaiement = patientsEnAttentePaiement;
        this.rdvDuJour = rdvDuJour;
    }

    public long getProduitsEnRupture() { return produitsEnRupture; }
    public long getProduitsSousLeSeuil() { return produitsSousLeSeuil; }
    public long getMouvementsAujourdHui() { return mouvementsAujourdHui; }
    public BigDecimal getDepensesStockDuJour() { return depensesStockDuJour; }
    public BigDecimal getRecettesPatientsDuJour() { return recettesPatientsDuJour; }
    public List<ProductDto> getAlertes() { return alertes; }
    public List<PatientDto> getPatientsEnAttentePaiement() { return patientsEnAttentePaiement; }
    public List<PatientDto> getRdvDuJour() { return rdvDuJour; }
}