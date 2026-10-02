package com.example.stock.patient.repository;

import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface PatientRepository extends JpaRepository<Patient, UUID> {

    @Query("""
        select new com.example.stock.patient.dto.PatientDto(
            p.id, p.prenom, p.nom, p.telephone, p.examenDemande, p.dateRdv)
        from Patient p
        order by p.dateCreation desc
        """)
    List<PatientDto> listAll();
}