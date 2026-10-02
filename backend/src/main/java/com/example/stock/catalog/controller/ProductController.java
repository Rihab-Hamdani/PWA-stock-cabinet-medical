package com.example.stock.catalog.controller;

import com.example.stock.catalog.dto.CreatedResponse;
import com.example.stock.catalog.dto.ProductDto;
import com.example.stock.catalog.dto.ProductRequest;
import com.example.stock.catalog.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @GetMapping
    public List<ProductDto> search(
            @RequestParam(required = false) UUID categorieId,
            @RequestParam(required = false) String nom) {
        return service.search(categorieId, nom);
    }

    @PostMapping
    public ResponseEntity<CreatedResponse> create(@Valid @RequestBody ProductRequest request) {
        UUID id = service.create(request);
        return ResponseEntity.ok(new CreatedResponse(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable UUID id, @Valid @RequestBody ProductRequest request) {
        service.update(id, request);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/desactiver")
    public ResponseEntity<Void> deactivate(@PathVariable UUID id) {
        service.deactivate(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/unites")
    public List<String> unites() {
        return service.listUnites();
    }
}