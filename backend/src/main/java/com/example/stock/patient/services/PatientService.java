package com.example.stock.patient.service;

import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.dto.PatientRequest;
import com.example.stock.patient.entity.Patient;
import com.example.stock.patient.repository.PatientRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PatientService {

    private final PatientRepository repository;

    public PatientService(PatientRepository repository) {
        this.repository = repository;
    }

    public List<PatientDto> list() {
        return repository.listAll();
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