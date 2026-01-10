package com.rmm.doctor_opointement.dto.appointment;

import java.time.LocalDateTime;

public record AppointmentDTO(
    Long id,
    String doctorName,
    String doctorSpeciality,
    LocalDateTime startTime,
    LocalDateTime endTime,
    String status
) {}
