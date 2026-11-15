package com.example.stock.shared.mail;

import jakarta.annotation.PostConstruct;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

/**
 * Point d'entrée unique pour l'envoi des emails de l'application.
 * L'expéditeur affiché est MAIL_FROM s'il est défini (adresse d'envoi
 * vérifiée dans Gmail), sinon MAIL_USER.
 */
@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final String username;
    private final String from;
    private final String fromName;
    private final String frontendUrl;

    public EmailService(JavaMailSender mailSender,
                        @Value("${spring.mail.username:}") String username,
                        @Value("${stock.mail.from:}") String from,
                        @Value("${stock.mail.from-name:Cabinet Médical}") String fromName,
                        @Value("${stock.frontend-url:http://localhost:4200}") String frontendUrl) {
        this.mailSender = mailSender;
        this.username = username;
        this.from = (from == null || from.isBlank()) ? username : from;
        this.fromName = fromName;
        this.frontendUrl = frontendUrl.replaceAll("/+$", "");
    }

    @PostConstruct
    void verifierConfiguration() {
        if (!isConfigured()) {
            log.warn("SMTP non configuré : définissez les variables MAIL_USER et MAIL_PASSWORD "
                    + "pour activer l'envoi des emails (activation de compte, mot de passe oublié).");
        } else {
            log.info("Envoi des emails activé via {} (expéditeur : {})", username, from);
        }
    }

    public boolean isConfigured() {
        return username != null && !username.isBlank();
    }

    public String frontendUrl() {
        return frontendUrl;
    }

    /**
     * Envoie un email texte. Ne lève jamais d'exception : un échec d'envoi
     * ne doit pas faire échouer l'action métier (activation, inscription…).
     *
     * @return true si l'email a été remis au serveur SMTP
     */
    public boolean send(String to, String subject, String body) {
        if (!isConfigured()) {
            log.warn("Email « {} » non envoyé à {} : SMTP non configuré.", subject, to);
            return false;
        }
        try {
            MimeMessage mime = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mime, false, "UTF-8");
            helper.setFrom(from, fromName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, false);
            mailSender.send(mime);
            log.info("Email « {} » envoyé à {}", subject, to);
            return true;
        } catch (Exception e) {
            log.error("Échec de l'envoi de l'email « {} » à {}", subject, to, e);
            return false;
        }
    }
}