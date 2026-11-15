package com.example.stock.patient.dto;

import java.math.BigDecimal;

public record PaiementRequest(boolean paye, BigDecimal montantPaye) {
}