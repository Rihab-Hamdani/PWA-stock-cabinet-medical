package com.example.stock.auth.controller;

import com.example.stock.auth.dto.UserDto;
import com.example.stock.auth.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.example.stock.auth.dto.UpdateProfileRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PutMapping;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/pending")
    @PreAuthorize("hasRole('MEDECIN')")
    public List<UserDto> pending() {
        return userService.listPending();
    }

    @PatchMapping("/{id}/activer")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<Void> activate(@PathVariable UUID id) {
        userService.activate(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<Void> reject(@PathVariable UUID id) {
        userService.reject(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/me")
    public UserDto updateMyProfile(@Valid @RequestBody UpdateProfileRequest request, Authentication authentication) {
        return userService.updateMyProfile(authentication.getName(), request);
    }

    @GetMapping("/pending/count")
    @PreAuthorize("hasRole('MEDECIN')")
    public long countPending() {
        return userService.countPending();
    }
}