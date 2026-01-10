package com.rmm.doctor_opointement.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.repository.DoctorRepository;

@Service
public class DoctorService {

    private final DoctorRepository doctorRepository;

    public DoctorService(DoctorRepository doctorRepository) {
        this.doctorRepository = doctorRepository;
    }

    // ================= CREATE =================
    public Doctor create(String name, String speciality) {
        Doctor doctor = new Doctor();
        doctor.setName(name);
        doctor.setSpeciality(speciality);
        return doctorRepository.save(doctor);
    }

    // ================= READ =================
 public Doctor findById(Long id) {
    if (id == null) {
        throw new IllegalArgumentException("Doctor id must not be null");
    }

    return doctorRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Doctor not found"));
}

    public List<Doctor> findAll() {
        return doctorRepository.findAll();
    }

    // ================= UPDATE =================
    public Doctor update(Long id, String name, String speciality) {
        Doctor doctor = findById(id);
        doctor.setName(name);
        doctor.setSpeciality(speciality);
        return doctorRepository.save(doctor);
    }

    // ================= DELETE =================
public void delete(Long id) {
    if (id == null) {
        throw new IllegalArgumentException("Doctor id must not be null");
    }

    Doctor doctor = doctorRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Doctor not found"));

    doctorRepository.delete(doctor);
}



}

