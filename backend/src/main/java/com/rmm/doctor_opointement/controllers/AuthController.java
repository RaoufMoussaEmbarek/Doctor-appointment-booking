package com.rmm.doctor_opointement.controllers;



import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import com.rmm.doctor_opointement.Security.AuthUser;
import com.rmm.doctor_opointement.Security.JwtUtil;
import com.rmm.doctor_opointement.dto.LoginRequest;
import com.rmm.doctor_opointement.dto.LoginResponse;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;



@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
    }

  @PostMapping("/login")
public LoginResponse login(@RequestBody LoginRequest request) {

  

    try {
   Authentication authentication = authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(
            request.getEmail(), 
            request.getPassword()
          
        )

        
    );

   AuthUser user = (AuthUser) authentication.getPrincipal();

      String token = jwtUtil.generateToken(
        user.getId(),
        user.getUsername(),
        user.getRole()
    );

    return new LoginResponse(token);



} catch (BadCredentialsException ex) {
        throw new ResponseStatusException(
            HttpStatus.UNAUTHORIZED,
            "Invalid email or password"
        );
    }


}}

