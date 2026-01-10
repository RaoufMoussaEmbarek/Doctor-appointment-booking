package com.rmm.doctor_opointement.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.rmm.doctor_opointement.model.Patient;
import com.rmm.doctor_opointement.repository.PatientRepository;

@Service
public class PatientService {

    private final PatientRepository patientRepository;

    public PatientService(PatientRepository patientRepository) {
        this.patientRepository = patientRepository;
    }

    // ================= CREATE =================
    public Patient create(String fullName, String email) {
        Patient patient = new Patient();
        patient.setFullName(fullName);
        patient.setEmail(email);
        return patientRepository.save(patient);
    }

    // ================= READ =================
public Patient findByUserId(Long userId) {
    return patientRepository.findByUser_Id(userId)
            .orElseThrow(() -> new RuntimeException("Patient not found"));
}

    public List<Patient> findAll() {
        return patientRepository.findAll();
    }

    // ================= UPDATE =================
    public Patient update(Long id, String email, String role) {
        Patient patient = findByUserId(id);
        patient.setFullName(email);
        patient.setEmail(email);
        return patientRepository.save(patient);
    }

    // ================= DELETE =================
    public void delete(Long id) {
        patientRepository.deleteById(id);
    }
}
