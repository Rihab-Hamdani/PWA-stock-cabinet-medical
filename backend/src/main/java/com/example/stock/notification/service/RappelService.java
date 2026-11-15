package com.example.stock.notification.service;

import com.example.stock.catalog.entity.Product;
import com.example.stock.catalog.repository.ProductRepository;
import com.example.stock.notification.dto.RappelDto;
import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class RappelService {

    private static final DateTimeFormatter HEURE = DateTimeFormatter.ofPattern("HH:mm");

    private final ProductRepository productRepository;
    private final PatientRepository patientRepository;
    private final ZoneId zone;
    private final int minutesAvant;

    public RappelService(ProductRepository productRepository,
                         PatientRepository patientRepository,
                         @Value("${stock.timezone:Africa/Tunis}") String fuseau,
                         @Value("${stock.rdv.rappel-minutes:45}") int minutesAvant) {
        this.productRepository = productRepository;
        this.patientRepository = patientRepository;
        this.zone = ZoneId.of(fuseau);
        this.minutesAvant = minutesAvant;
    }

    public List<RappelDto> courants() {
        List<RappelDto> liste = new ArrayList<>();
        ajouterRendezVous(liste);
        ajouterStock(liste);
        return liste;
    }

    private void ajouterRendezVous(List<RappelDto> liste) {
        LocalDateTime maintenant = LocalDateTime.now(zone);
        LocalTime de = maintenant.toLocalTime();
        LocalTime a = de.plusMinutes(minutesAvant);
        if (a.isBefore(de)) {
            a = LocalTime.MAX; // la fenêtre passe minuit : on s'arrête à la fin de la journée
        }

        for (PatientDto r : patientRepository.rdvProches(maintenant.toLocalDate(), de, a)) {
            long minutes = Math.max(0, Duration.between(de, r.heureRdv()).toMinutes());
            String quand = minutes == 0 ? "maintenant" : "dans " + minutes + " min";
            String examen = (r.examenDemande() == null || r.examenDemande().isBlank())
                    ? "" : " — " + r.examenDemande();

            liste.add(new RappelDto(
                    "rdv-" + r.id() + "-" + maintenant.toLocalDate(),
                    "RDV_PROCHE",
                    "Rendez-vous " + quand,
                    r.prenom() + " " + r.nom() + " à " + r.heureRdv().format(HEURE) + examen,
                    "/agenda"));
        }
    }

    private void ajouterStock(List<RappelDto> liste) {
        for (Product p : productRepository.findStockBas()) {
            boolean rupture = p.getQuantiteActuelle() == 0;
            String etat = rupture ? "RUPTURE" : "BAS";
            String message = rupture
                    ? p.getNom() + " est épuisé."
                    : p.getNom() + " : " + p.getQuantiteActuelle() + " " + p.getUnite()
                    + " restant(s) (seuil " + p.getSeuilAlerte() + ")";

            liste.add(new RappelDto(
                    "stock-" + p.getId() + "-" + etat,
                    rupture ? "STOCK_RUPTURE" : "STOCK_BAS",
                    rupture ? "Rupture de stock" : "Stock bas",
                    message,
                    "/produits/" + p.getId()));
        }
    }
}