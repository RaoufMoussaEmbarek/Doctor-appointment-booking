package com.rmm.doctor_opointement.controllers;

import com.rmm.doctor_opointement.dto.doctor.DoctorDTO;
import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.services.AppointmentService;
import com.rmm.doctor_opointement.services.DoctorService;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/doctors")
public class DoctorController {

    private final AppointmentService appointmentService;
    private final DoctorService doctorService;

    public DoctorController(
            DoctorService doctorService,
            AppointmentService appointmentService
    ) {
        this.doctorService = doctorService;
        this.appointmentService = appointmentService;
    }

    // ================= ALL DOCTORS =================
    @GetMapping
    public List<DoctorDTO> allDoctors() {
        return doctorService.findAll()
                .stream()
                .map(d -> new DoctorDTO(
                        d.getId(),
                        d.getName(),
                        d.getSpeciality()
                ))
                .toList();
    }

    // ================= AVAILABILITY =================
    @GetMapping("/{id}/availability")
    public List<String> availability(
            @PathVariable Long id,
            @RequestParam String date
    ) {
        Doctor doctor = doctorService.findById(id);
        LocalDate day = LocalDate.parse(date);

        List<LocalTime> slots = List.of(
                LocalTime.of(9, 0),
                LocalTime.of(9, 30),
                LocalTime.of(10, 0),
                LocalTime.of(10, 30),
                LocalTime.of(11, 0),
                LocalTime.of(11, 30),
                LocalTime.of(16, 0),
                LocalTime.of(17, 0),
                LocalTime.of(18, 0),
                LocalTime.of(19, 0)
        );

        return slots.stream()
                .filter(time -> {
                    LocalDateTime start = LocalDateTime.of(day, time);
                    LocalDateTime end = start.plusMinutes(30);
                    return appointmentService.isSlotFree(
                            doctor, start, end
                    );
                })
                .map(LocalTime::toString)
                .toList();
    }
}
