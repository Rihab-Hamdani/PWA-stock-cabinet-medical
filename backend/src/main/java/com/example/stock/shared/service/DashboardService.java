package com.example.stock.shared.service;

import com.example.stock.catalog.repository.ProductRepository;
import com.example.stock.inventory.repository.MovementRepository;
import com.example.stock.patient.repository.PatientRepository;
import com.example.stock.shared.dto.DashboardDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;

@Service
public class DashboardService {

    private final ProductRepository productRepository;
    private final MovementRepository movementRepository;
    private final PatientRepository patientRepository;
    private final ZoneId zone;

    public DashboardService(ProductRepository productRepository,
                            MovementRepository movementRepository,
                            PatientRepository patientRepository,
                            @Value("${stock.timezone:Africa/Tunis}") String fuseau) {
        this.productRepository = productRepository;
        this.movementRepository = movementRepository;
        this.patientRepository = patientRepository;
        this.zone = ZoneId.of(fuseau);
    }

    public DashboardDto get(boolean estMedecin) {
        long rupture = productRepository.countRupture();
        long sousLeSeuil = productRepository.countSousLeSeuil();
        long mouvements = movementRepository.countMouvementsAujourdHui();

        BigDecimal depenses = estMedecin ? movementRepository.montantEntreesAujourdHui() : null;
        BigDecimal recettes = estMedecin ? patientRepository.recettesDuJour() : null;

        var alertes = productRepository.findAlertes(PageRequest.of(0, 5));
        var aPayer = patientRepository.aPayerAujourdhui(LocalDate.now(zone));
        var rdv = patientRepository.rdvDuJour(LocalDate.now(zone));
        return new DashboardDto(rupture, sousLeSeuil, mouvements, depenses, recettes, alertes, aPayer, rdv);
    }
}