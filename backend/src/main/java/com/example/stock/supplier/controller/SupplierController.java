package com.example.stock.supplier.controller;

import com.example.stock.supplier.dto.SupplierDto;
import com.example.stock.supplier.dto.SupplierRequest;
import com.example.stock.supplier.service.SupplierService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/suppliers")
public class SupplierController {

    private final SupplierService service;

    public SupplierController(SupplierService service) {
        this.service = service;
    }

    @GetMapping
    public List<SupplierDto> search(@RequestParam(required = false) String nom) {
        return service.search(nom);
    }

    @PostMapping
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<Void> create(@Valid @RequestBody SupplierRequest request) {
        service.create(request);
        return ResponseEntity.ok().build();
    }
}