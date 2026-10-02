package com.example.stock.catalog.service;

import com.example.stock.catalog.dto.ProductDto;
import com.example.stock.catalog.dto.ProductRequest;
import com.example.stock.catalog.entity.Product;
import com.example.stock.catalog.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.UUID;

@Service
public class ProductService {

    private final ProductRepository repository;

    public ProductService(ProductRepository repository) {
        this.repository = repository;
    }

    public List<ProductDto> search(UUID categorieId, String nom) {
        return repository.search(categorieId, (nom == null || nom.isBlank()) ? null : nom);
    }

    public UUID create(ProductRequest request) {
        Product product = new Product();
        apply(product, request);
        return repository.save(product).getId();
    }

    public void update(UUID id, ProductRequest request) {
        Product product = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));
        apply(product, request);
        repository.save(product);
    }

    public void deactivate(UUID id) {
        Product product = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));
        product.setActif(false);
        repository.save(product);
    }

    private void apply(Product product, ProductRequest request) {
        product.setNom(request.getNom());
        product.setCategorieId(request.getCategorieId());
        product.setUnite(request.getUnite());
        product.setSeuilAlerte(request.getSeuilAlerte());
        product.setPrixUnitaireHt(request.getPrixUnitaireHt());
        product.setDatePeremption(request.getDatePeremption());
        product.setNumeroLot(request.getNumeroLot());
    }
    public void sortieRapide(UUID id) {
        Product product = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));

        int nouvelleQuantite = product.getQuantiteActuelle() - 1;
        if (nouvelleQuantite < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Stock déjà à zéro.");
        }
        product.setQuantiteActuelle(nouvelleQuantite);
        repository.save(product);
    }

    public List<String> listUnites() {
        return repository.findDistinctUnites();
    }
}