package com.rmm.doctor_opointement.controllers;



import com.rmm.doctor_opointement.dto.patient.CreatePatientRequest;
import com.rmm.doctor_opointement.dto.patient.PatientDTO;
import com.rmm.doctor_opointement.dto.patient.UpdatePatientRequest;
import com.rmm.doctor_opointement.model.Patient;
import com.rmm.doctor_opointement.services.PatientService;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/patients")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    // ================= CREATE =================
    @PostMapping
    public PatientDTO create(@RequestBody CreatePatientRequest req) {

        Patient patient = patientService.create(
                req.fullName(),
                req.email()
        );

        return toDTO(patient);
    }

    // ================= READ =================
    @GetMapping("/{id}")
    public PatientDTO getById(@PathVariable Long id) {
        return toDTO(patientService.findByUserId(id));
    }

    @GetMapping
    public List<PatientDTO> all() {
        return patientService.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    // ================= UPDATE =================
    @PutMapping("/{id}")
    public PatientDTO update(
            @PathVariable Long id,
            @RequestBody UpdatePatientRequest req
    ) {
        Patient patient = patientService.update(
                id,
                req.fullName(),
                req.email()
        );

        return toDTO(patient);
    }

    // ================= DELETE =================
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        patientService.delete(id);
    }

    // ================= MAPPER =================
    private PatientDTO toDTO(Patient p) {
        return new PatientDTO(
                p.getId(),
                p.getFullName(),
                p.getEmail()
        );
    }
}
