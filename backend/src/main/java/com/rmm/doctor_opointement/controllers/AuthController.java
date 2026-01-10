package com.rmm.doctor_opointement.controllers;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.rmm.doctor_opointement.Security.JWTutil;
import com.rmm.doctor_opointement.model.User;
import com.rmm.doctor_opointement.services.UserService;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;
    private final JWTutil jwtUtil;

    public AuthController(UserService userService, JWTutil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        try {
            User user = userService.authenticate(
                req.username(),
                req.password()
            );

            return ResponseEntity.ok(
                Map.of("token", jwtUtil.generate(user))
            );

        } catch (RuntimeException e) {
            return ResponseEntity
                .status(401)
                .body("Invalid credentials");
        }
    }
}

record LoginRequest(String username, String password) {}
