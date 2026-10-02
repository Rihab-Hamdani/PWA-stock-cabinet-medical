package com.example.stock.shared.config;

import com.example.stock.auth.entity.Role;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${stock.admin.email}")
    private String adminEmail;

    @Value("${stock.admin.password}")
    private String adminPassword;

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (userRepository.count() > 0) return;

        User medecin = new User();
        medecin.setNom("Cabinet");
        medecin.setPrenom("Dr.");
        medecin.setEmail(adminEmail);
        medecin.setMotDePasse(passwordEncoder.encode(adminPassword));
        medecin.setRole(Role.MEDECIN);
        medecin.setActif(true);
        userRepository.save(medecin);

        log.info("Compte médecin initial créé -> email: {} / mot de passe: {}", adminEmail, adminPassword);
    }
}