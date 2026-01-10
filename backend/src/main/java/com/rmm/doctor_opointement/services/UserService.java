package com.rmm.doctor_opointement.services;

import java.util.List;

import com.rmm.doctor_opointement.model.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;


@Service
public class UserService {
    
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    private final List<User> users = List.of(
        new User(1L, "patient1", encoder.encode("password"), "PATIENT"),
        new User(2L, "patient2", encoder.encode("password"), "PATIENT"),
        new User(3L, "patient3", encoder.encode("password"), "PATIENT"),
        new User(4L, "patient4", encoder.encode("password"), "PATIENT"),
        new User(5L, "patient5", encoder.encode("password"), "PATIENT")
      
    );

    public User authenticate(String username, String rawPassword) {
        return users.stream()
            .filter(u -> u.username().equals(username))
            .filter(u -> encoder.matches(rawPassword, u.passwordHash()))
            .findFirst()
            .orElseThrow(() -> new RuntimeException("Invalid credentials"));
    }
}
