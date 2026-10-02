package com.example.stock.catalog.controller;

import com.example.stock.catalog.dto.CategoryDto;
import com.example.stock.catalog.dto.CategoryRequest;
import com.example.stock.catalog.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/categories")
public class CategoryController {

    private final CategoryService service;

    public CategoryController(CategoryService service) {
        this.service = service;
    }

    @GetMapping
    public List<CategoryDto> search(@RequestParam(required = false) String nom) {
        return service.search(nom);
    }

    @PostMapping
    public ResponseEntity<Void> create(@Valid @RequestBody CategoryRequest request) {
        service.create(request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.ok().build();
    }
}