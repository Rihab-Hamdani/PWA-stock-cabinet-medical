package com.example.stock.auth.service;

import com.example.stock.auth.dto.UserDto;
import com.example.stock.auth.dto.UpdateProfileRequest;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpStatus;
import com.example.stock.shared.mail.EmailService;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository repository;
    private final EmailService emailService;

    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }

    public List<UserDto> listPending() {
        return repository.findByActifFalse().stream()
                .map(u -> new UserDto(u.getId(), u.getNom(), u.getPrenom(), u.getEmail(),
                        u.getTelephone(), u.getRole(), u.isActif()))
                .toList();
    }

    public long countPending() {
        return repository.countByActifFalse();
    }

    public void activate(UUID id) {
        User user = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Compte introuvable"));
        user.setActif(true);
        repository.save(user);

        emailService.send(user.getEmail(),
                "Votre compte a été activé — Cabinet Médical",
                "Bonjour " + user.getPrenom() + ",\n\n"
                        + "Votre compte sur l'application de gestion du cabinet a été validé par le médecin.\n"
                        + "Vous pouvez désormais vous connecter avec votre email et votre mot de passe :\n"
                        + emailService.frontendUrl() + "/login\n\n"
                        + "Cordialement.");
    }

    public void reject(UUID id) {
        User user = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Compte introuvable"));
        repository.delete(user);

        emailService.send(user.getEmail(),
                "Votre demande de compte — Cabinet Médical",
                "Bonjour " + user.getPrenom() + ",\n\n"
                        + "Votre demande de création de compte n'a pas été acceptée par le médecin.\n"
                        + "Pour toute question, merci de le contacter directement.\n\n"
                        + "Cordialement.");
    }

    public UserDto updateMyProfile(String email, @NonNull UpdateProfileRequest request) {
        User user = repository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));

        user.setPrenom(request.getPrenom());
        user.setNom(request.getNom());
        user.setTelephone(request.getTelephone());
        repository.save(user);

        return new UserDto(user.getId(), user.getNom(), user.getPrenom(), user.getEmail(),
                user.getTelephone(), user.getRole(), user.isActif());
    }
}