package com.rmm.doctor_opointement.controllers;

import com.rmm.doctor_opointement.dto.appointment.CreateAppointmentRequest;
import com.rmm.doctor_opointement.model.Appointment;
import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.model.Patient;
import com.rmm.doctor_opointement.Security.AuthUser;
import com.rmm.doctor_opointement.services.AppointmentService;
import com.rmm.doctor_opointement.services.DoctorService;
import com.rmm.doctor_opointement.services.PatientService;

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/appointments")
public class AppointmentController {

    private final AppointmentService appointmentService;
    private final DoctorService doctorService;
    private final PatientService patientService;

    public AppointmentController(
            AppointmentService appointmentService,
            DoctorService doctorService,
            PatientService patientService
    ) {
        this.appointmentService = appointmentService;
        this.doctorService = doctorService;
        this.patientService = patientService;
    }

    private Patient currentPatient() {
        Authentication auth =
                SecurityContextHolder.getContext().getAuthentication();

        AuthUser user = (AuthUser) auth.getPrincipal();

        return patientService.findByUserId(user.getId());
    }

    // ================= CREATE =================
    @PostMapping
    public Appointment create(@RequestBody CreateAppointmentRequest req) {

        Patient patient = currentPatient();
        Doctor doctor = doctorService.findById(req.doctorId());

        return appointmentService.create(
                patient,
                doctor,
                req.startTime(),
                req.endTime()
        );
    }

    // ================= READ =================
    @GetMapping("/me")
    public List<Map<String, Object>> myAppointments() {

        Patient patient = currentPatient();

        return appointmentService.findByPatient(patient)
                .stream()
                .map(a -> Map.of(
                        "id", a.getId(),
                        "doctor", Map.of(
                                "id", a.getDoctor().getId(),
                                "name", a.getDoctor().getName(),
                                "speciality", a.getDoctor().getSpeciality()
                        ),
                        "startTime", a.getStartTime(),
                        "endTime", a.getEndTime(),
                        "status", a.getStatus()
                ))
                .toList();
    }

    // ================= CANCEL =================
    @PutMapping("/{id}/cancel")
    public void cancel(@PathVariable Long id) {

        System.out.println("canceling appointement "+ id);

        Patient patient = currentPatient();
        appointmentService.cancelByPatient(id, patient);
    }

    // ================= RESCHEDULE =================
    @PutMapping("/{id}/reschedule")
    public Appointment reschedule(
            @PathVariable Long id,
            @RequestBody Map<String, String> body
    ) {

        Patient patient = currentPatient();

        LocalDateTime startTime = LocalDateTime.parse(body.get("startTime"));
        LocalDateTime endTime = LocalDateTime.parse(body.get("endTime"));

        return appointmentService.rescheduleByPatient(
                id,
                patient,
                startTime,
                endTime
        );
    }
}
