package com.rmm.doctor_opointement.repository;
import com.rmm.doctor_opointement.model.Patient;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PatientRepository extends JpaRepository <Patient, Long> {
Optional<Patient> findByUser_Id(Long userId);
}

