package com.example.stock.auth.service;

import com.example.stock.auth.dto.UserDto;
import com.example.stock.auth.dto.UpdateProfileRequest;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpStatus;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository repository;
    private final JavaMailSender mailSender;

    public UserService(UserRepository repository, JavaMailSender mailSender) {
        this.repository = repository;
        this.mailSender = mailSender;
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

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(user.getEmail());
            message.setSubject("Votre compte a été activé");
            message.setText("Bonjour " + user.getPrenom() + ",\n\n"
                    + "Votre compte sur l'application de gestion du cabinet a été validé par le médecin.\n"
                    + "Vous pouvez désormais vous connecter avec votre email et votre mot de passe.\n\n"
                    + "Cordialement.");
            mailSender.send(message);
        } catch (Exception e) {
            // l'échec d'envoi ne doit pas empêcher l'activation
        }
    }

    public void reject(UUID id) {
        repository.deleteById(id);
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