package com.example.stock.catalog.service;

import com.example.stock.catalog.dto.CategoryDto;
import com.example.stock.catalog.dto.CategoryRequest;
import com.example.stock.catalog.dto.CategoryTrashDto;
import com.example.stock.catalog.entity.Category;
import com.example.stock.catalog.entity.Product;
import com.example.stock.catalog.repository.CategoryRepository;
import com.example.stock.catalog.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class CategoryService {

    private static final Duration RETENTION = Duration.ofHours(24);

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
        if (repository.existsByNomIgnoreCaseAndDeletedAtIsNull(request.getNom())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cette catégorie existe déjà.");
        }
        if (repository.existsByNomIgnoreCaseAndDeletedAtIsNotNull(request.getNom())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Une catégorie portant ce nom est dans la corbeille. Restaurez-la, ou supprimez-la définitivement depuis la corbeille pour libérer le nom.");
        }
        if (repository.existsByNomIgnoreCaseAndDeletedAtIsNotNull(request.getNom())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Une catégorie portant ce nom est dans la corbeille. Restaurez-la, ou supprimez-la définitivement depuis la corbeille pour libérer le nom.");
        }

        Category category = new Category();
        category.setNom(request.getNom());
        repository.save(category);

        Product product = new Product();
        product.setNom(request.getProduitNom());
        product.setCategorieId(category.getId());
        product.setUnite(request.getUnite());
        product.setSeuilAlerte(request.getSeuilAlerte());
        product.setPrixUnitaireHt(BigDecimal.ZERO);
        productRepository.save(product);
    }

    // ---- Corbeille ----

    @Transactional
    public void delete(UUID id) {
        Category category = find(id);
        Instant now = Instant.now();
        category.setDeletedAt(now);
        repository.save(category);

        for (Product p : productRepository.findByCategorieIdAndActifTrue(id)) {
            p.setActif(false);
            p.setDeletedAt(now);
        }
    }

    public List<CategoryTrashDto> listTrash() {
        return repository.findByDeletedAtIsNotNullAndPurgedAtIsNullOrderByDeletedAtDesc().stream()
                .map(c -> new CategoryTrashDto(c.getId(), c.getNom(), c.getDeletedAt()))
                .toList();
    }

    @Transactional
    public void restore(UUID id) {
        Category category = find(id);
        if (category.getDeletedAt() == null) return;

        boolean nomPris = repository.search(category.getNom()).stream()
                .anyMatch(c -> c.getNom().equalsIgnoreCase(category.getNom()));
        if (nomPris) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Une catégorie portant ce nom existe déjà.");
        }

        category.setDeletedAt(null);
        for (Product p : productRepository.findByCategorieIdAndDeletedAtIsNotNull(id)) {
            p.setActif(true);
            p.setDeletedAt(null);
        }
    }

    @Transactional
    public void deletePermanently(UUID id) {
        Category category = find(id);
        if (category.getDeletedAt() == null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Mettez d'abord la catégorie à la corbeille.");
        }
        purge(category);
    }

    @Transactional
    public void purgeExpired() {
        Instant limite = Instant.now().minus(RETENTION);
        repository.findByDeletedAtBeforeAndPurgedAtIsNull(limite).forEach(this::purge);
    }

    // Archivage définitif : la catégorie disparaît de l'app, mais ses produits
    // et tous leurs mouvements restent en base (historique, chiffres du dashboard).
    private void purge(Category category) {
        Instant now = Instant.now();
        category.setPurgedAt(now);
        // libère le nom pour pouvoir recréer une catégorie du même nom
        category.setNom(category.getNom() + " [supprimée " + now.toEpochMilli() + "]");
        repository.save(category);
    }

    private Category find(UUID id) {
        Category category = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Catégorie introuvable"));
        if (category.getPurgedAt() != null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Catégorie introuvable");
        }
        return category;
    }
}