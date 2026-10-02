package com.example.stock.inventory.repository;

import com.example.stock.inventory.dto.MovementDto;
import com.example.stock.inventory.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface MovementRepository extends JpaRepository<Movement, UUID> {

    @Query("select count(m) from Movement m where m.dateMouvement = CURRENT_DATE")
    long countMouvementsAujourdHui();

    @Query(value = """
        select coalesce(sum(prix_total_ttc), 0) from movements
        where type = 'ENTREE' and date_mouvement = current_date
        """, nativeQuery = true)
    BigDecimal montantEntreesAujourdHui();

    @Query(value = """
        select coalesce(sum(prix_total_ht), 0) from movements
        where type = 'SORTIE' and date_mouvement = current_date
        """, nativeQuery = true)
    BigDecimal montantPerteAujourdHui();

    @Query("""
        select new com.example.stock.inventory.dto.MovementDto(
            m.id, m.type, m.quantite, m.dateMouvement, m.heureMouvement,
            m.prixUnitaireHt, m.prixTotalHt, m.prixTotalTtc,
            s.nom, m.numeroFacture, m.motif,
            concat(u.prenom, ' ', u.nom))
        from Movement m
        join User u on u.id = m.utilisateurId
        left join Supplier s on s.id = m.fournisseurId
        where m.produitId = :produitId
        order by m.dateMouvement desc, m.heureMouvement desc
        """)
    List<MovementDto> findByProduitId(@Param("produitId") UUID produitId);
}