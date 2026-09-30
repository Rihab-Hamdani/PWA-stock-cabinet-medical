# Stock Cabinet Médical

Application de gestion de stock pour un cabinet médical spécialisé en exploration fonctionnelle (EEG, EMG, PEA, PEV, ERG, PES, EFR/Spiro...). Progressive Web App installable sur mobile et desktop, permettant au médecin et à la/aux secrétaire(s) de suivre en temps réel les entrées et sorties de produits, d'être alertés en cas de rupture de stock, et de gérer les rendez-vous patients.

## Fonctionnalités

### Authentification & rôles
- Connexion sécurisée par JWT
- Deux rôles : **Médecin** (accès complet) et **Secrétaire**
- Inscription libre avec validation par le médecin (le tout premier compte créé devient automatiquement médecin)
- Réinitialisation de mot de passe par email (Brevo)
- Gestion des comptes en attente/actifs depuis un écran d'administration

### Stock
- Catégories de produits, créées avec leur premier produit
- Fiche produit : nom, unité, quantité, seuil d'alerte, prix unitaire HT, péremption, numéro de lot
- Recherche et filtrage par catégorie
- Sortie rapide ("Utiliser") et arrivage complet (quantité, prix, TVA, fournisseur — sélectionné dans une liste ou saisi manuellement avec téléphone, numéro de facture)
- Historique complet et horodaté des mouvements par produit
- Gestion des fournisseurs

### Tableau de bord
- Vue adaptée au rôle connecté : produits en rupture / sous le seuil, mouvements du jour
- Indicateurs financiers réservés au médecin : valeur du stock, montant des entrées du jour, montant perdu (sorties valorisées)
- Alertes de stock avec accès direct à la fiche produit

### Patients
- Fiche d'identification patient (identité, coordonnées)
- Informations de rendez-vous (examen demandé, médecin traitant, clinique, date)
- Suivi de paiement (assurance, montant payé, remarques)

## Stack technique

| Couche | Technologie |
|---|---|
| Frontend | Angular 18 (standalone components, signals), PWA |
| Backend | Spring Boot 4.1 (Java 21), architecture monolithe modulaire |
| Base de données | PostgreSQL |
| Authentification | Spring Security 6 + JWT (jjwt) |
| Email | Brevo (SMTP) |
| Outils | IntelliJ IDEA, DBeaver |

## Architecture backend

Monolithe modulaire organisé par domaine métier :
