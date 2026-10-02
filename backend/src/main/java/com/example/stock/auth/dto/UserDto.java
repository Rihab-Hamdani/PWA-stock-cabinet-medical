package com.example.stock.auth.dto;

import com.example.stock.auth.entity.Role;
import java.util.UUID;

public class UserDto {
    private final UUID id;
    private final String nom;
    private final String prenom;
    private final String email;
    private final String telephone;
    private final Role role;
    private final boolean actif;

    public UserDto(UUID id, String nom, String prenom, String email, String telephone, Role role, boolean actif) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.telephone = telephone;
        this.role = role;
        this.actif = actif;
    }

    public UUID getId() { return id; }
    public String getNom() { return nom; }
    public String getPrenom() { return prenom; }
    public String getEmail() { return email; }
    public String getTelephone() { return telephone; }
    public Role getRole() { return role; }
    public boolean isActif() { return actif; }
}