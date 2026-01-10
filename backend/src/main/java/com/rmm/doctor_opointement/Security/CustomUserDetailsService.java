package com.rmm.doctor_opointement.Security;

import com.rmm.doctor_opointement.repository.UserRepository;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email)  {
    System.out.println("AUTH LOOKUP EMAIL = " + email);
         

        return userRepository.findByEmail(email)
                .map(AuthUser::new)
                .orElseThrow(() ->
                        new UsernameNotFoundException("User not found"));
    }
}
