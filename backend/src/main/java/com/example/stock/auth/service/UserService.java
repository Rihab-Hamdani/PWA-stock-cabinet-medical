package com.example.stock.auth.service;

import com.example.stock.auth.dto.UserDto;
import com.example.stock.auth.entity.User;
import com.example.stock.auth.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public List<UserDto> listPending() {
        return repository.findByActifFalse().stream()
                .map(u -> new UserDto(u.getId(), u.getNom(), u.getPrenom(), u.getEmail(),
                        u.getTelephone(), u.getRole(), u.isActif()))
                .toList();
    }

    public void activate(UUID id) {
        User user = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Compte introuvable"));
        user.setActif(true);
        repository.save(user);
    }

    public void reject(UUID id) {
        repository.deleteById(id);
    }
}