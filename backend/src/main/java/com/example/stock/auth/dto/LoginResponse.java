package com.example.stock.auth.dto;

import lombok.Getter;

@Getter
public class LoginResponse {
    private final String token;
    private final UserDto user;

    public LoginResponse(String token, UserDto user) {
        this.token = token;
        this.user = user;
    }

}