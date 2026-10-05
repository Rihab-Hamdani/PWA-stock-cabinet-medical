package com.example.stock.catalog.repository;

import com.example.stock.catalog.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface CategoryRepository extends JpaRepository<Category, UUID> {

    @Query("""
        select c from Category c
        where c.deletedAt is null
          and (cast(:nom as string) is null or lower(c.nom) like lower(concat('%', cast(:nom as string), '%')))
        order by c.nom
        """)
    List<Category> search(@Param("nom") String nom);

    List<Category> findByDeletedAtIsNotNullAndPurgedAtIsNullOrderByDeletedAtDesc();

    List<Category> findByDeletedAtBeforeAndPurgedAtIsNull(Instant limite);

    boolean existsByNomIgnoreCaseAndDeletedAtIsNull(String nom);

    boolean existsByNomIgnoreCaseAndDeletedAtIsNotNull(String nom);
}