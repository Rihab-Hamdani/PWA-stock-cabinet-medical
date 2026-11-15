package com.example.stock.patient.service;

import com.example.stock.patient.dto.PatientDetailDto;
import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.dto.PatientRequest;
import com.example.stock.patient.entity.Patient;
import com.example.stock.patient.repository.PatientRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class PatientService {

    private static final Set<String> STATUTS =
            Set.of("PLANIFIE",  "EN_CONSULTATION", "TERMINE", "ANNULE");

    private final PatientRepository repository;

    public PatientService(PatientRepository repository) {
        this.repository = repository;
    }

    public List<PatientDto> list() {
        return repository.listAll();
    }

    public List<PatientDto> agenda(LocalDate du, LocalDate au) {
        if (au.isBefore(du)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Période invalide.");
        }
        return repository.agenda(du, au);
    }

    public PatientDetailDto get(UUID id) {
        Patient p = find(id);
        return new PatientDetailDto(p.getId(), p.getEmail(), p.getPrenom(), p.getNom(), p.getDateNaissance(),
                p.getSexe(), p.getTelephone(), p.getAdresse(), p.getExamenDemande(), p.getMedecinTraitant(),
                p.getClinique(), p.getDateRdv(), p.getHeureRdv(), p.getStatut(), p.isPaye(),
                p.getAssurance(), p.getMontantPaye(), p.getRemarques());
    }

    public void create(PatientRequest request) {
        Patient p = new Patient();
        appliquer(p, request);
        repository.save(p);
    }

    public void update(UUID id, PatientRequest request) {
        Patient p = find(id);
        appliquer(p, request);
        repository.save(p);
    }

    public void delete(UUID id) {
        if (!repository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Patient introuvable");
        }
        repository.deleteById(id);
    }

    public void changerStatut(UUID id, String statut) {
        Patient p = find(id);
        p.setStatut(verifierStatut(statut));
        repository.save(p);
    }

    public void changerPaiement(UUID id, boolean paye, BigDecimal montantPaye) {
        Patient p = find(id);
        p.setPaye(paye);
        if (montantPaye != null) {
            p.setMontantPaye(montantPaye);
        }
        repository.save(p);
    }

    private Patient find(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Patient introuvable"));
    }

    private String verifierStatut(String statut) {
        String valeur = (statut == null || statut.isBlank()) ? "PLANIFIE" : statut;
        if (!STATUTS.contains(valeur)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Statut inconnu : " + valeur);
        }
        return valeur;
    }

    private void appliquer(Patient p, PatientRequest r) {
        p.setEmail(r.email());
        p.setPrenom(r.prenom());
        p.setNom(r.nom());
        p.setDateNaissance(r.dateNaissance());
        p.setSexe(r.sexe());
        p.setTelephone(r.telephone());
        p.setAdresse(r.adresse());
        p.setExamenDemande(r.examenDemande());
        p.setMedecinTraitant(r.medecinTraitant());
        p.setClinique(r.clinique());
        p.setDateRdv(r.dateRdv());
        p.setHeureRdv(r.heureRdv());
        p.setStatut(verifierStatut(r.statut()));
        p.setPaye(r.paye());
        p.setAssurance(r.assurance());
        p.setMontantPaye(r.montantPaye());
        p.setRemarques(r.remarques());
    }
}