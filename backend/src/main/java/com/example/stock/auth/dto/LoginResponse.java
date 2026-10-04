package com.example.stock.auth.dto;

public class LoginResponse {
    private final String token;
    private final UserDto user;

    public LoginResponse(String token, UserDto user) {
        this.token = token;
        this.user = user;
    }

    public String getToken() { return token; }
    public UserDto getUser() { return user; }
}