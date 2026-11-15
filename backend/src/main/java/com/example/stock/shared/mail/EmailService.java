package com.example.stock.shared.mail;

import jakarta.annotation.PostConstruct;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

/**
 * Envoi des emails : par API HTTPS si MAIL_API_KEY est défini
 * (utile sur les hébergeurs qui bloquent le SMTP), sinon par SMTP.
 */
@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final String username;
    private final String from;
    private final String fromName;
    private final String frontendUrl;
    private final String apiKey;
    private final String apiSecret;
    private final RestClient http = RestClient.create();

    public EmailService(JavaMailSender mailSender,
                        @Value("${spring.mail.username:}") String username,
                        @Value("${stock.mail.from:}") String from,
                        @Value("${stock.mail.from-name:Cabinet Médical}") String fromName,
                        @Value("${stock.mail.api-key:}") String apiKey,
                        @Value("${stock.mail.api-secret:}") String apiSecret,
                        @Value("${stock.frontend-url:http://localhost:4200}") String frontendUrl) {
        this.mailSender = mailSender;
        this.username = username;
        this.from = (from == null || from.isBlank()) ? username : from;
        this.fromName = fromName;
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
        this.frontendUrl = frontendUrl.replaceAll("/+$", "");
    }

    private boolean useApi() {
        return apiKey != null && !apiKey.isBlank() && apiSecret != null && !apiSecret.isBlank();
    }

    @PostConstruct
    void verifierConfiguration() {
        if (useApi()) {
            log.info("Envoi des emails par API HTTPS (expéditeur : {})", from);
        } else if (isConfigured()) {
            log.info("Envoi des emails par SMTP via {} (expéditeur : {})", username, from);
        } else {
            log.warn("Aucun envoi d'email configuré (MAIL_API_KEY ou MAIL_USER/MAIL_PASSWORD).");
        }
    }

    public boolean isConfigured() {
        return useApi() || (username != null && !username.isBlank());
    }

    public String frontendUrl() {
        return frontendUrl;
    }

    public boolean send(String to, String subject, String body) {
        if (!isConfigured()) {
            log.warn("Email « {} » non envoyé à {} : envoi non configuré.", subject, to);
            return false;
        }
        try {
            if (useApi()) {
                sendByApi(to, subject, body);
            } else {
                sendBySmtp(to, subject, body);
            }
            log.info("Email « {} » envoyé à {}", subject, to);
            return true;
        } catch (Exception e) {
            log.error("Échec de l'envoi de l'email « {} » à {}", subject, to, e);
            return false;
        }
    }

    private void sendBySmtp(String to, String subject, String body) throws Exception {
        MimeMessage mime = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mime, false, "UTF-8");
        helper.setFrom(from, fromName);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(body, false);
        mailSender.send(mime);
    }

    /** Exemple pour Mailjet (API v3.1). Pour un autre service, changer l'URL, l'authentification et le corps. */
    private void sendByApi(String to, String subject, String body) {
        Map<String, Object> message = Map.of(
                "From", Map.of("Email", from, "Name", fromName),
                "To", List.of(Map.of("Email", to)),
                "Subject", subject,
                "TextPart", body);
        String basic = java.util.Base64.getEncoder()
                .encodeToString((apiKey + ":" + apiSecret).getBytes(java.nio.charset.StandardCharsets.UTF_8));
        http.post()
                .uri("https://api.mailjet.com/v3.1/send")
                .header("Authorization", "Basic " + basic)
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .body(Map.of("Messages", List.of(message)))
                .retrieve()
                .toBodilessEntity();
    }
}