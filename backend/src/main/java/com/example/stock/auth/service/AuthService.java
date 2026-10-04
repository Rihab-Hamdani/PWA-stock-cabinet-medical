package com.example.stock.auth.service;

import com.example.stock.auth.dto.LoginRequest;
import com.example.stock.auth.dto.LoginResponse;
import com.example.stock.auth.dto.RegisterRequest;
import com.example.stock.auth.dto.ResetPasswordRequest;
import com.example.stock.auth.dto.UserDto;
import com.example.stock.auth.entity.Role;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import com.example.stock.auth.security.JwtService;
import com.example.stock.auth.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final JavaMailSender mailSender;

    public AuthService(AuthenticationManager authenticationManager,
                       UserRepository userRepository,
                       JwtService jwtService,
                       PasswordEncoder passwordEncoder,
                       JavaMailSender mailSender) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
        this.mailSender = mailSender;
    }

    public void register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Un compte existe déjà avec cet email.");
        }

        boolean estPremierCompte = userRepository.count() == 0;

        User user = new User();
        user.setNom(request.getNom());
        user.setPrenom(request.getPrenom());
        user.setEmail(request.getEmail());
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));

        if (estPremierCompte) {
            user.setRole(Role.MEDECIN);
            user.setActif(true);
        } else {
            user.setRole(Role.SECRETAIRE);
            user.setActif(false);
        }

        userRepository.save(user);
    }

    public LoginResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getMotDePasse()));

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Identifiants invalides"));

        String token = jwtService.generateToken(new UserPrincipal(user));

        UserDto dto = new UserDto(user.getId(), user.getNom(), user.getPrenom(), user.getEmail(),
                user.getTelephone(), user.getRole(), user.isActif());

        return new LoginResponse(token, dto);
    }

    public void forgotPassword(String email) {
        userRepository.findByEmail(email).ifPresent(user -> {
            String token = UUID.randomUUID().toString();
            user.setResetToken(token);
            user.setResetTokenExpiration(Instant.now().plus(1, ChronoUnit.HOURS));
            userRepository.save(user);

            String lien = "http://localhost:4200/reinitialiser-mot-de-passe?token=" + token;

            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setTo(user.getEmail());
                message.setSubject("Réinitialisation de votre mot de passe — Stock Cabinet");
                message.setText("Bonjour " + user.getPrenom() + ",\n\n"
                        + "Cliquez sur ce lien pour réinitialiser votre mot de passe (valable 1h) :\n"
                        + lien + "\n\nSi vous n'êtes pas à l'origine de cette demande, ignorez cet email.");
                mailSender.send(message);
            } catch (Exception e) {
                log.warn("Envoi d'email impossible (SMTP non configuré) — lien de réinitialisation : {}", lien);
            }
        });
        // Pas d'exception si l'email n'existe pas : on ne révèle jamais si un compte existe ou non.
    }

    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByResetToken(request.getToken())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lien invalide ou expiré."));

        if (user.getResetTokenExpiration() == null || user.getResetTokenExpiration().isBefore(Instant.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lien invalide ou expiré.");
        }

        user.setMotDePasse(passwordEncoder.encode(request.getNouveauMotDePasse()));
        user.setResetToken(null);
        user.setResetTokenExpiration(null);
        userRepository.save(user);
    }


}