package com.rmm.doctor_opointement.dto.patient;

public record UpdatePatientRequest(
        String fullName,
        String email
) {}