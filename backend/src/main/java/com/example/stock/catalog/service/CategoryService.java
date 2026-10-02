package com.example.stock.catalog.service;

import com.example.stock.catalog.dto.CategoryDto;
import com.example.stock.catalog.dto.CategoryRequest;
import com.example.stock.catalog.entity.Category;
import com.example.stock.catalog.entity.Product;
import com.example.stock.catalog.repository.CategoryRepository;
import com.example.stock.catalog.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class CategoryService {

    private final CategoryRepository repository;
    private final ProductRepository productRepository;

    public CategoryService(CategoryRepository repository, ProductRepository productRepository) {
        this.repository = repository;
        this.productRepository = productRepository;
    }

    public List<CategoryDto> search(String nom) {
        return repository.search((nom == null || nom.isBlank()) ? null : nom).stream()
                .map(c -> new CategoryDto(c.getId(), c.getNom()))
                .toList();
    }

    @Transactional
    public void create(CategoryRequest request) {
        boolean existeDeja = repository.search(request.getNom()).stream()
                .anyMatch(c -> c.getNom().equalsIgnoreCase(request.getNom()));
        if (existeDeja) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cette catégorie existe déjà.");
        }

        Category category = new Category();
        category.setNom(request.getNom());
        repository.save(category);

        Product product = new Product();
        product.setNom(request.getProduitNom());
        product.setCategorieId(category.getId());
        product.setUnite(request.getUnite());
        product.setSeuilAlerte(request.getSeuilAlerte());
        product.setPrixUnitaireHt(java.math.BigDecimal.ZERO);
        productRepository.save(product);
    }

    public void delete(UUID id) {
        long produits = productRepository.countByCategorieId(id);
        if (produits > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Impossible de supprimer : cette catégorie contient " + produits + " produit(s). Supprimez-les d'abord.");
        }
        repository.deleteById(id);
    }
}