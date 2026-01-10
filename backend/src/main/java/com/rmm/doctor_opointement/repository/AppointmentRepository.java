package com.rmm.doctor_opointement.repository;

import com.rmm.doctor_opointement.model.Appointment;
import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.model.Patient;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // ================= FIND =================
    List<Appointment> findByPatient(Patient patient);

    // ================= OVERLAP CHECK =================
    @Query("""
        SELECT COUNT(a) > 0
        FROM Appointment a
        WHERE a.doctor = :doctor
          AND a.startTime < :end
          AND :start < a.endTime
          AND a.status <> 'CANCELLED'
    """)
    boolean existsOverlapping(
        @Param("doctor") Doctor doctor,
        @Param("start") LocalDateTime start,
        @Param("end") LocalDateTime end
    );

    @Query("""
        SELECT COUNT(a) > 0
        FROM Appointment a
        WHERE a.doctor = :doctor
          AND a.id <> :excludeId
          AND a.startTime < :end
          AND :start < a.endTime
          AND a.status <> 'CANCELLED'
    """)
    boolean existsOverlappingExcluding(
        @Param("doctor") Doctor doctor,
        @Param("start") LocalDateTime start,
        @Param("end") LocalDateTime end,
        @Param("excludeId") Long excludeId
    );
}


