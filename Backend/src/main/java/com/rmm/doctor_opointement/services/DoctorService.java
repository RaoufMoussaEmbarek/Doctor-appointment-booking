package com.rmm.doctor_opointement.services;

import com.rmm.doctor_opointement.model.Doctor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DoctorService {

    private final List<Doctor> doctors = List.of(
        new Doctor(1L, "Dr Smith", "Cardiology"),
        new Doctor(2L, "Dr Ahmed", "General Medicine"),
        new Doctor(3L, "Dr Laura", "Dermatology")
    );

    public List<Doctor> findAll() {
        return doctors;
    }

    public Doctor findById(Long id) {
        return doctors.stream()
                .filter(d -> d.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Doctor not found"));
    }
}

