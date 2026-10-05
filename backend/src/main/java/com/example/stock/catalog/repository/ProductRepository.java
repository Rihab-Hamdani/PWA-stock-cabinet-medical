package com.example.stock.catalog.repository;

import com.example.stock.catalog.dto.ProductDto;
import com.example.stock.catalog.entity.Product;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {

    @Query("""
        select new com.example.stock.catalog.dto.ProductDto(
            p.id, p.nom, p.categorieId, c.nom, p.unite, p.quantiteActuelle, p.seuilAlerte,
            p.prixUnitaireHt, p.datePeremption, p.numeroLot)
        from Product p join Category c on c.id = p.categorieId
        where p.actif = true
          and (:categorieId is null or p.categorieId = :categorieId)
          and (cast(:nom as string) is null or lower(p.nom) like lower(concat('%', cast(:nom as string), '%')))
        order by p.nom
        """)
    List<ProductDto> search(@Param("categorieId") UUID categorieId, @Param("nom") String nom);

    @Query("select count(p) from Product p where p.actif = true and p.quantiteActuelle = 0")
    long countRupture();

    @Query("select count(p) from Product p where p.actif = true and p.quantiteActuelle > 0 and p.quantiteActuelle <= p.seuilAlerte")
    long countSousLeSeuil();

    @Query("select coalesce(sum(p.quantiteActuelle * p.prixUnitaireHt), 0) from Product p where p.actif = true")
    BigDecimal valeurStock();

    @Query("select distinct p.unite from Product p where p.actif = true order by p.unite")
    List<String> findDistinctUnites();

    @Query("""
        select new com.example.stock.catalog.dto.ProductDto(
            p.id, p.nom, p.categorieId, c.nom, p.unite, p.quantiteActuelle, p.seuilAlerte,
            p.prixUnitaireHt, p.datePeremption, p.numeroLot)
        from Product p join Category c on c.id = p.categorieId
        where p.actif = true and p.quantiteActuelle <= p.seuilAlerte
        order by (p.quantiteActuelle - p.seuilAlerte) asc
        """)
    List<ProductDto> findAlertes(Pageable pageable);

    List<Product> findByCategorieIdAndActifTrue(UUID categorieId);

    List<Product> findByCategorieIdAndDeletedAtIsNotNull(UUID categorieId);
}