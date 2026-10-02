package com.example.stock.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequest {

    @NotBlank
    private String token;

    @NotBlank @Size(min = 6, message = "6 caractères minimum")
    private String nouveauMotDePasse;

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getNouveauMotDePasse() { return nouveauMotDePasse; }
    public void setNouveauMotDePasse(String nouveauMotDePasse) { this.nouveauMotDePasse = nouveauMotDePasse; }
}