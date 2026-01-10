package com.rmm.doctor_opointement.model;
import java.time.LocalDateTime;

public record appointment (
 
    Long id,
    Long patientId,
    Long doctorId,
    LocalDateTime startTime,
    LocalDateTime endTime
){}