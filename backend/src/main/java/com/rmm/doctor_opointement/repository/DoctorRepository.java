package com.rmm.doctor_opointement.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.rmm.doctor_opointement.model.Doctor;

public interface DoctorRepository extends JpaRepository<Doctor, Long> {
}

