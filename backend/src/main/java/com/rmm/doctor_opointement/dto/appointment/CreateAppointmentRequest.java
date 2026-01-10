package com.rmm.doctor_opointement.dto.appointment;

import java.time.LocalDateTime;

public record CreateAppointmentRequest(
    Long doctorId,
    LocalDateTime startTime,
    LocalDateTime endTime
) {}
