package com.example.stock.patient.service;

import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.dto.PatientRequest;
import com.example.stock.patient.entity.Patient;
import com.example.stock.patient.repository.PatientRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import com.example.stock.patient.dto.PatientDetailDto;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.util.UUID;


@Service
public class PatientService {

    private final PatientRepository repository;

    public PatientService(PatientRepository repository) {
        this.repository = repository;
    }

    public List<PatientDto> list() {
        return repository.listAll();
    }

    public PatientDetailDto get(UUID id) {
        Patient p = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Patient introuvable"));
        return toDetailDto(p);
    }

    public void update(UUID id, PatientRequest request) {
        Patient p = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Patient introuvable"));

        p.setEmail(request.getEmail());
        p.setPrenom(request.getPrenom());
        p.setNom(request.getNom());
        p.setDateNaissance(request.getDateNaissance());
        p.setSexe(request.getSexe());
        p.setTelephone(request.getTelephone());
        p.setAdresse(request.getAdresse());
        p.setExamenDemande(request.getExamenDemande());
        p.setMedecinTraitant(request.getMedecinTraitant());
        p.setClinique(request.getClinique());
        p.setDateRdv(request.getDateRdv());
        p.setAssurance(request.getAssurance());
        p.setMontantPaye(request.getMontantPaye());
        p.setRemarques(request.getRemarques());
        repository.save(p);
    }

    private PatientDetailDto toDetailDto(Patient p) {
        return new PatientDetailDto(p.getId(), p.getEmail(), p.getPrenom(), p.getNom(), p.getDateNaissance(),
                p.getSexe(), p.getTelephone(), p.getAdresse(), p.getExamenDemande(), p.getMedecinTraitant(),
                p.getClinique(), p.getDateRdv(), p.getAssurance(), p.getMontantPaye(), p.getRemarques());
    }

    public void create(PatientRequest request) {
        Patient patient = new Patient();
        patient.setEmail(request.getEmail());
        patient.setPrenom(request.getPrenom());
        patient.setNom(request.getNom());
        patient.setDateNaissance(request.getDateNaissance());
        patient.setSexe(request.getSexe());
        patient.setTelephone(request.getTelephone());
        patient.setAdresse(request.getAdresse());
        patient.setExamenDemande(request.getExamenDemande());
        patient.setMedecinTraitant(request.getMedecinTraitant());
        patient.setClinique(request.getClinique());
        patient.setDateRdv(request.getDateRdv());
        patient.setAssurance(request.getAssurance());
        patient.setMontantPaye(request.getMontantPaye());
        patient.setRemarques(request.getRemarques());
        repository.save(patient);
    }


}