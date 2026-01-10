package com.rmm.doctor_opointement.model;

public record User(
    Long id,
    String username,
    String passwordHash,
    String role
) {}
