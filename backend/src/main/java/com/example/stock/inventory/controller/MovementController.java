package com.example.stock.inventory.controller;

import com.example.stock.inventory.dto.MovementDto;
import com.example.stock.inventory.dto.MovementEntreeRequest;
import com.example.stock.inventory.service.MovementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/movements")
public class MovementController {

    private final MovementService service;

    public MovementController(MovementService service) {
        this.service = service;
    }

    @PostMapping("/{produitId}/entree")
    public ResponseEntity<Void> entree(
            @PathVariable UUID produitId,
            @Valid @RequestBody MovementEntreeRequest request) {
        service.enregistrerEntree(produitId, request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{produitId}/sortie-rapide")
    public ResponseEntity<Void> sortieRapide(@PathVariable UUID produitId) {
        service.enregistrerSortie(produitId, 1, null);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/produit/{produitId}")
    public List<MovementDto> historiqueProduit(@PathVariable UUID produitId) {
        return service.historiqueProduit(produitId);
    }
}