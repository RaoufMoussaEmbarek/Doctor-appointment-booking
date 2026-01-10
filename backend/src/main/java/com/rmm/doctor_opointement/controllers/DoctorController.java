package com.rmm.doctor_opointement.controllers;

import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.services.AppointmentService;
import com.rmm.doctor_opointement.services.DoctorService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/doctors")
public class DoctorController {

    private final AppointmentService appointmentService;

    private final DoctorService doctorService;

    public DoctorController(DoctorService doctorService, AppointmentService appointmentService) {
        this.doctorService = doctorService;
        this.appointmentService = appointmentService;
    }

    @GetMapping
    public List<Doctor> allDoctors() {
        return doctorService.findAll();
    }

    @GetMapping("/{id}/availability")
public List<String> availability(
        @PathVariable Long id,
        @RequestParam String date
) {
    // Mock working hours: 09:00 → 12:00, 30-min slots
    List<String> allSlots = List.of(
        "09:00", "09:30",
        "10:00", "10:30",
        "11:00", "11:30",
        "16:00","17:00",
        "18:00","19:00"
    );

    // Remove already booked slots for that doctor/date
    return allSlots.stream()
            .filter(slot -> appointmentService.isFree(id, date, slot))
            .toList();
}

}

