package com.example.stock.patient.controller;

import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.dto.PatientRequest;
import com.example.stock.patient.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.stock.patient.dto.PatientDetailDto;
import java.util.UUID;

import java.util.List;

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

    @PostMapping
    public ResponseEntity<Void> create(@Valid @RequestBody PatientRequest request) {
        service.create(request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    public PatientDetailDto get(@PathVariable UUID id) {
        return service.get(id);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable UUID id, @Valid @RequestBody PatientRequest request) {
        service.update(id, request);
        return ResponseEntity.ok().build();
    }


}