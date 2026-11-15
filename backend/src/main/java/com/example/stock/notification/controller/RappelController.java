package com.example.stock.notification.controller;

import com.example.stock.notification.dto.RappelDto;
import com.example.stock.notification.service.RappelService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/rappels")
public class RappelController {

    private final RappelService service;

    public RappelController(RappelService service) {
        this.service = service;
    }

    @GetMapping
    public List<RappelDto> list() {
        return service.courants();
    }
}