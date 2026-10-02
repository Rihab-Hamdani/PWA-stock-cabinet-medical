package com.example.stock.shared.service;

import com.example.stock.catalog.repository.ProductRepository;
import com.example.stock.inventory.repository.MovementRepository;
import com.example.stock.shared.dto.DashboardDto;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class DashboardService {

    private final ProductRepository productRepository;
    private final MovementRepository movementRepository;

    public DashboardService(ProductRepository productRepository, MovementRepository movementRepository) {
        this.productRepository = productRepository;
        this.movementRepository = movementRepository;
    }

    public DashboardDto get(boolean estMedecin) {
        long rupture = productRepository.countRupture();
        long sousLeSeuil = productRepository.countSousLeSeuil();
        long mouvements = movementRepository.countMouvementsAujourdHui();

        BigDecimal montantDuJour = estMedecin ? movementRepository.montantEntreesAujourdHui() : null;
        BigDecimal montantPerdu = estMedecin ? movementRepository.montantPerteAujourdHui() : null;
        BigDecimal valeurDuStock = estMedecin ? productRepository.valeurStock() : null;

        var alertes = productRepository.findAlertes(PageRequest.of(0, 5));

        return new DashboardDto(rupture, sousLeSeuil, mouvements, montantDuJour, montantPerdu, valeurDuStock, alertes);
    }
}