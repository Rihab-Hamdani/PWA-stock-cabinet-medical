package com.example.stock.auth.service;

import com.example.stock.auth.dto.*;
import com.example.stock.auth.entity.Role;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import com.example.stock.auth.security.JwtService;
import com.example.stock.auth.security.UserPrincipal;
import com.example.stock.shared.mail.EmailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
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
    private final EmailService emailService;

    public AuthService(AuthenticationManager authenticationManager,
                       UserRepository userRepository,
                       JwtService jwtService,
                       PasswordEncoder passwordEncoder,
                       EmailService emailService) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }

    private static String normaliser(String email) {
        return email == null ? "" : email.trim().toLowerCase();
    }

    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        String email = normaliser(request.getEmail());

        if (userRepository.findByEmail(email).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Un compte existe déjà avec cet email.");
        }

        // Premier compte d'une base vide = la docteure : médecin, actif immédiatement.
        boolean estPremierCompte = userRepository.count() == 0;

        User user = new User();
        user.setNom(request.getNom());
        user.setPrenom(request.getPrenom());
        user.setEmail(email);
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));

        if (estPremierCompte) {
            user.setRole(Role.MEDECIN);
            user.setActif(true);
        } else {
            user.setRole(Role.SECRETAIRE);
            user.setActif(false);
        }

        userRepository.save(user);

        if (!estPremierCompte) {
            notifierMedecinsNouvelleInscription(user);
        }
        return new RegisterResponse(estPremierCompte);
    }

    private void notifierMedecinsNouvelleInscription(User secretaire) {
        userRepository.findByRoleAndActifTrue(Role.MEDECIN).forEach(medecin -> {
            boolean envoye = emailService.send(medecin.getEmail(),
                    "Nouvelle demande de compte — Cabinet Médical",
                    "Bonjour Dr " + medecin.getNom() + ",\n\n"
                            + secretaire.getPrenom() + " " + secretaire.getNom()
                            + " (" + secretaire.getEmail() + ") a créé un compte secrétaire.\n"
                            + "Ce compte doit être validé avant de pouvoir se connecter :\n"
                            + emailService.frontendUrl() + "\n\n"
                            + "Cordialement.");
            log.info("Email de demande de compte pour {} : {}", medecin.getEmail(),
                    envoye ? "ENVOYÉ" : "ÉCHEC");
        });
    }

    public LoginResponse login(LoginRequest request) {
        String email = normaliser(request.getEmail());

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, request.getMotDePasse()));

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadCredentialsException("Identifiants invalides"));

        String token = jwtService.generateToken(new UserPrincipal(user));

        UserDto dto = new UserDto(user.getId(), user.getNom(), user.getPrenom(), user.getEmail(),
                user.getTelephone(), user.getRole(), user.isActif());

        return new LoginResponse(token, dto);
    }

    public void forgotPassword(String emailBrut) {
        String email = normaliser(emailBrut);
        userRepository.findByEmail(email).ifPresent(user -> {
            String token = UUID.randomUUID().toString();
            user.setResetToken(token);
            user.setResetTokenExpiration(Instant.now().plus(1, ChronoUnit.HOURS));
            userRepository.save(user);

            String lien = emailService.frontendUrl() + "/reinitialiser-mot-de-passe?token=" + token;

            boolean envoye = emailService.send(user.getEmail(),
                    "Réinitialisation de votre mot de passe — Cabinet Médical",
                    "Bonjour " + user.getPrenom() + ",\n\n"
                            + "Cliquez sur ce lien pour réinitialiser votre mot de passe (valable 1h) :\n"
                            + lien + "\n\nSi vous n'êtes pas à l'origine de cette demande, ignorez cet email.");
            if (!envoye) {
                log.warn("Lien de réinitialisation pour {} (email non envoyé) : {}", user.getEmail(), lien);
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