package com.example.stock.inventory.service;

import com.example.stock.auth.security.UserPrincipal;
import com.example.stock.catalog.entity.Product;
import com.example.stock.catalog.entity.Supplier;
import com.example.stock.catalog.repository.ProductRepository;
import com.example.stock.inventory.dto.MovementDto;
import com.example.stock.inventory.dto.MovementEntreeRequest;
import com.example.stock.inventory.entity.Movement;
import com.example.stock.inventory.entity.MovementType;
import com.example.stock.inventory.repository.MovementRepository;
import com.example.stock.supplier.repository.SupplierRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
public class MovementService {

    private static final BigDecimal TVA = new BigDecimal("20.00");

    private final MovementRepository movementRepository;
    private final ProductRepository productRepository;
    private final SupplierRepository supplierRepository;

    public MovementService(MovementRepository movementRepository, ProductRepository productRepository,
                           SupplierRepository supplierRepository) {
        this.movementRepository = movementRepository;
        this.productRepository = productRepository;
        this.supplierRepository = supplierRepository;
    }

    public void enregistrerEntree(UUID produitId, MovementEntreeRequest request) {
        Product product = productRepository.findById(produitId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));

        UUID fournisseurId = request.getFournisseurId();
        if (fournisseurId == null && request.getFournisseurNom() != null && !request.getFournisseurNom().isBlank()) {
            fournisseurId = resoudreOuCreerFournisseur(request.getFournisseurNom(), request.getFournisseurTelephone());
        }

        BigDecimal prixUnitaireHt = request.getPrixUnitaireHt();
        BigDecimal prixUnitaireTtc = prixUnitaireHt.multiply(BigDecimal.ONE.add(TVA.divide(new BigDecimal("100"))));
        BigDecimal quantite = new BigDecimal(request.getQuantite());
        BigDecimal prixTotalHt = prixUnitaireHt.multiply(quantite);
        BigDecimal prixTotalTtc = prixUnitaireTtc.multiply(quantite);

        Movement movement = new Movement();
        movement.setProduitId(produitId);
        movement.setUtilisateurId(currentUserId());
        movement.setType(MovementType.ENTREE);
        movement.setQuantite(request.getQuantite());
        movement.setPrixUnitaireHt(prixUnitaireHt);
        movement.setTva(TVA);
        movement.setPrixUnitaireTtc(prixUnitaireTtc);
        movement.setPrixTotalHt(prixTotalHt);
        movement.setPrixTotalTtc(prixTotalTtc);
        movement.setFournisseurId(fournisseurId);
        movement.setNumeroFacture(request.getNumeroFacture());
        movementRepository.save(movement);

        product.setQuantiteActuelle(product.getQuantiteActuelle() + request.getQuantite());
        productRepository.save(product);
    }

    public void enregistrerSortie(UUID produitId, int quantite, String motif) {
        Product product = productRepository.findById(produitId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));

        if (quantite > product.getQuantiteActuelle()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Stock insuffisant.");
        }

        BigDecimal prixUnitaireHt = product.getPrixUnitaireHt() != null ? product.getPrixUnitaireHt() : BigDecimal.ZERO;
        BigDecimal prixTotalHt = prixUnitaireHt.multiply(BigDecimal.valueOf(quantite));

        Movement movement = new Movement();
        movement.setProduitId(produitId);
        movement.setUtilisateurId(currentUserId());
        movement.setType(MovementType.SORTIE);
        movement.setQuantite(quantite);
        movement.setPrixUnitaireHt(prixUnitaireHt);
        movement.setPrixTotalHt(prixTotalHt);
        movement.setMotif(motif);
        movementRepository.save(movement);

        product.setQuantiteActuelle(product.getQuantiteActuelle() - quantite);
        productRepository.save(product);
    }

    public List<MovementDto> historiqueProduit(UUID produitId) {
        return movementRepository.findByProduitId(produitId);
    }

    private UUID resoudreOuCreerFournisseur(String nom, String telephone) {
        return supplierRepository.search(nom).stream()
                .filter(s -> s.getNom().equalsIgnoreCase(nom))
                .findFirst()
                .map(Supplier::getId)
                .orElseGet(() -> {
                    Supplier supplier = new Supplier();
                    supplier.setNom(nom);
                    supplier.setTelephone(telephone);
                    return supplierRepository.save(supplier).getId();
                });
    }

    private UUID currentUserId() {
        UserPrincipal principal = (UserPrincipal) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        return principal.getUser().getId();
    }
}