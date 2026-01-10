package com.rmm.doctor_opointement.controllers;



import com.rmm.doctor_opointement.model.appointment;
import com.rmm.doctor_opointement.services.AppointmentService;
import org.springframework.web.bind.annotation.*;


import java.time.LocalDateTime;
import java.util.List;

import com.rmm.doctor_opointement.services.DoctorService;
import com.rmm.doctor_opointement.model.Doctor;
import java.util.Map;


import org.springframework.security.core.context.SecurityContextHolder;

@RestController
@RequestMapping("/appointments")
public class AppointmentController {

    private final AppointmentService appointmentService;
   
private final DoctorService doctorService;

   public AppointmentController(
    AppointmentService appointmentService,
    DoctorService doctorService
) {
    this.appointmentService = appointmentService;
    this.doctorService = doctorService;
}

    @PostMapping
    public appointment create(@RequestBody CreateAppointmentRequest req) {

        Long patientId = Long.valueOf(
            SecurityContextHolder.getContext()
                .getAuthentication()
                .getName()
        );

        return appointmentService.create(
            patientId,
            req.doctorId(),
            req.startTime(),
            req.endTime()
        );
    }

@GetMapping("/me")
public List<Map<String, Object>> myAppointments() {

    Long patientId = Long.valueOf(
        SecurityContextHolder.getContext()
            .getAuthentication()
            .getName()
    );

    return appointmentService.findByPatient(patientId)
        .stream()
        .map(a -> {
            Doctor d = doctorService.findById(a.doctorId());

            return Map.of(
                "id", a.id(),
                "doctor", Map.of(
                    "id", d.id(),
                    "name", d.name(),
                    "speciality", d.speciality()
                ),
                "startTime", a.startTime(),
                "endTime", a.endTime()
            );
        })
        .toList();
}

@PutMapping("/{id}/cancel")
public void cancel(@PathVariable Long id) {

    Long patientId = Long.valueOf(
        SecurityContextHolder.getContext()
            .getAuthentication()
            .getName()
    );

    appointmentService.cancelByPatient(id, patientId);
}

@PutMapping("/{id}/reschedule")
public void reschedule(
        @PathVariable Long id,
        @RequestBody Map<String, String> body
) {

    Long patientId = Long.valueOf(
        SecurityContextHolder.getContext()
            .getAuthentication()
            .getName()
    );

    LocalDateTime startTime =
        LocalDateTime.parse(body.get("startTime"));
    LocalDateTime endTime =
        LocalDateTime.parse(body.get("endTime"));

    appointmentService.rescheduleByPatient(
        id,
        patientId,
        startTime,
        endTime
    );
}


}

record CreateAppointmentRequest(
    Long doctorId,
    LocalDateTime startTime,
    LocalDateTime endTime
) {}

