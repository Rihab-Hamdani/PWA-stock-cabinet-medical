package com.example.stock.patient.repository;

import com.example.stock.patient.dto.PatientDto;
import com.example.stock.patient.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public interface PatientRepository extends JpaRepository<Patient, UUID> {

    @Query("""
        select new com.example.stock.patient.dto.PatientDto(
            p.id, p.prenom, p.nom, p.telephone, p.examenDemande,
            p.dateRdv, p.heureRdv, p.statut, p.paye)
        from Patient p
        order by p.dateCreation desc
        """)
    List<PatientDto> listAll();

    @Query("""
        select new com.example.stock.patient.dto.PatientDto(
            p.id, p.prenom, p.nom, p.telephone, p.examenDemande,
            p.dateRdv, p.heureRdv, p.statut, p.paye)
        from Patient p
        where p.dateRdv between :du and :au
        order by p.dateRdv asc, p.heureRdv asc nulls last, p.nom asc
        """)
    List<PatientDto> agenda(@Param("du") LocalDate du, @Param("au") LocalDate au);

    @Query("""
        select p from Patient p
        where p.dateRdv = :jour and p.heureRdv is not null
          and p.heureRdv >= :de and p.heureRdv <= :a
          and p.statut = 'PLANIFIE'
        order by p.heureRdv asc
        """)
    List<Patient> rdvAVenir(@Param("jour") LocalDate jour, @Param("de") LocalTime de, @Param("a") LocalTime a);
    @Query("""
    select new com.example.stock.patient.dto.PatientDto(
        p.id, p.prenom, p.nom, p.telephone, p.examenDemande,
        p.dateRdv, p.heureRdv, p.statut, p.paye)
    from Patient p
    where p.dateRdv = :date
      and p.statut in ('PLANIFIE', 'EN_CONSULTATION')
      and p.paye = false
    order by case when p.statut = 'EN_CONSULTATION' then 0 else 1 end,
             p.heureRdv asc nulls last, p.nom asc
    """)
    List<PatientDto> aPayerAujourdhui(@Param("date") LocalDate date);

    @Query("""
    select new com.example.stock.patient.dto.PatientDto(
        p.id, p.prenom, p.nom, p.telephone, p.examenDemande,
        p.dateRdv, p.heureRdv, p.statut, p.paye)
    from Patient p
    where p.dateRdv = :date
    order by p.heureRdv asc nulls last, p.nom asc
    """)
    List<PatientDto> rdvDuJour(@Param("date") LocalDate date);

    @Query(value = """
        select coalesce(sum(montant_paye), 0) from patients
        where date_rdv = current_date and paye = true and statut <> 'ANNULE'
        """, nativeQuery = true)
    BigDecimal recettesDuJour();

    @Query("""
    select new com.example.stock.patient.dto.PatientDto(
        p.id, p.prenom, p.nom, p.telephone, p.examenDemande,
        p.dateRdv, p.heureRdv, p.statut, p.paye)
    from Patient p
    where p.dateRdv = :date and p.statut = 'PLANIFIE'
      and p.heureRdv between :de and :a
    order by p.heureRdv asc
    """)
    List<PatientDto> rdvProches(@Param("date") LocalDate date,
                                @Param("de") LocalTime de,
                                @Param("a") LocalTime a);
}