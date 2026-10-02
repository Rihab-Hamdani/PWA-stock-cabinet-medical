package com.example.stock.supplier.service;

import com.example.stock.catalog.entity.Supplier;
import com.example.stock.supplier.dto.SupplierDto;
import com.example.stock.supplier.dto.SupplierRequest;
import com.example.stock.supplier.repository.SupplierRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierService {

    private final SupplierRepository repository;

    public SupplierService(SupplierRepository repository) {
        this.repository = repository;
    }

    public List<SupplierDto> search(String nom) {
        return repository.search((nom == null || nom.isBlank()) ? null : nom).stream()
                .map(s -> new SupplierDto(s.getId(), s.getNom(), s.getTelephone()))
                .toList();
    }

    public void create(SupplierRequest request) {
        Supplier supplier = new Supplier();
        supplier.setNom(request.getNom());
        supplier.setTelephone(request.getTelephone());
        repository.save(supplier);
    }
}