package com.rmm.doctor_opointement.dto.patient;

public record CreatePatientRequest(
        String fullName,
        String email
) {}
