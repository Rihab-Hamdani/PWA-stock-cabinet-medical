package com.example.stock.patient.controller;

import com.example.stock.patient.dto.PaiementRequest;
import com.example.stock.patient.dto.PatientDetailDto;
import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.dto.PatientRequest;
import com.example.stock.patient.dto.StatutRequest;
import com.example.stock.patient.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/patients")
public class PatientController {

    private final PatientService service;

    public PatientController(PatientService service) {
        this.service = service;
    }

    @GetMapping
    public List<PatientDto> list() {
        return service.list();
    }

    @GetMapping("/agenda")
    public List<PatientDto> agenda(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate du,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate au) {
        return service.agenda(du, au);
    }

    @GetMapping("/{id}")
    public PatientDetailDto get(@PathVariable UUID id) {
        return service.get(id);
    }

    @PostMapping
    public ResponseEntity<Void> create(@Valid @RequestBody PatientRequest request) {
        service.create(request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable UUID id, @Valid @RequestBody PatientRequest request) {
        service.update(id, request);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/statut")
    public ResponseEntity<Void> statut(@PathVariable UUID id, @Valid @RequestBody StatutRequest request) {
        service.changerStatut(id, request.statut());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/paiement")
    public ResponseEntity<Void> paiement(@PathVariable UUID id, @RequestBody PaiementRequest request) {
        service.changerPaiement(id, request.paye(), request.montantPaye());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.ok().build();
    }
}