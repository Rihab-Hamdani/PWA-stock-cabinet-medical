package com.example.stock.supplier.repository;

import com.example.stock.catalog.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface SupplierRepository extends JpaRepository<Supplier, UUID> {

    @Query("""
        select s from Supplier s
        where s.actif = true
          and (cast(:nom as string) is null or lower(s.nom) like lower(concat('%', cast(:nom as string), '%')))
        order by s.nom
        """)
    List<Supplier> search(@Param("nom") String nom);
}