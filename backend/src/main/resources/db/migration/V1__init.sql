-- ============================================================
-- STOCK — Migration initiale (Flyway V1)
-- Gestion de stock pour cabinet médical
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------- 1. USERS ----------
CREATE TABLE users (
                       id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       nom             VARCHAR(100)  NOT NULL,
                       prenom          VARCHAR(100)  NOT NULL,
                       email           VARCHAR(150)  NOT NULL UNIQUE,
                       mot_de_passe    VARCHAR(255)  NOT NULL,
                       telephone       VARCHAR(30),
                       role            VARCHAR(20)   NOT NULL DEFAULT 'SECRETAIRE'
                           CHECK (role IN ('MEDECIN', 'SECRETAIRE')),
                       actif           BOOLEAN       NOT NULL DEFAULT TRUE,
                       date_creation   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ---------- 2. CATEGORIES ----------
CREATE TABLE categories (
                            id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                            nom             VARCHAR(100)  NOT NULL UNIQUE
);

-- ---------- 3. SUPPLIERS (fournisseurs) ----------
CREATE TABLE suppliers (
                           id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                           nom             VARCHAR(150)  NOT NULL,
                           telephone       VARCHAR(30),
                           email           VARCHAR(150),
                           actif           BOOLEAN       NOT NULL DEFAULT TRUE,
                           date_creation   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ---------- 4. PRODUCTS ----------
CREATE TABLE products (
                          id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                          nom                 VARCHAR(150)  NOT NULL,
                          categorie_id        UUID          NOT NULL REFERENCES categories(id),
                          unite               VARCHAR(50)   NOT NULL DEFAULT 'pièce',
                          quantite_actuelle   INTEGER       NOT NULL DEFAULT 0 CHECK (quantite_actuelle >= 0),
                          seuil_alerte        INTEGER       NOT NULL DEFAULT 5 CHECK (seuil_alerte >= 0),
                          prix_unitaire_ht    NUMERIC(10,2) DEFAULT 0,
                          date_peremption     DATE,
                          numero_lot          VARCHAR(80),
                          actif               BOOLEAN       NOT NULL DEFAULT TRUE,
                          date_creation       TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX idx_products_categorie ON products(categorie_id);
CREATE INDEX idx_products_actif     ON products(actif);

-- ---------- 5. MOVEMENTS ----------
CREATE TABLE movements (
                           id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                           produit_id          UUID          NOT NULL REFERENCES products(id),
                           utilisateur_id      UUID          NOT NULL REFERENCES users(id),
                           type                VARCHAR(20)   NOT NULL CHECK (type IN ('ENTREE', 'SORTIE')),
                           quantite            INTEGER       NOT NULL CHECK (quantite > 0),
                           date_mouvement      DATE          NOT NULL DEFAULT CURRENT_DATE,
                           heure_mouvement     TIME          NOT NULL DEFAULT CURRENT_TIME,
    -- ENTREE
                           prix_unitaire_ht    NUMERIC(10,2),
                           tva                 NUMERIC(4,2)  DEFAULT 20.00,
                           prix_unitaire_ttc   NUMERIC(10,2),
                           prix_total_ht       NUMERIC(10,2),
                           prix_total_ttc      NUMERIC(10,2),
                           fournisseur_id      UUID REFERENCES suppliers(id),
                           numero_facture      VARCHAR(80),
    -- SORTIE
                           motif               VARCHAR(255),
                           date_creation       TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX idx_movements_produit ON movements(produit_id);
CREATE INDEX idx_movements_date    ON movements(date_mouvement);
CREATE INDEX idx_movements_user    ON movements(utilisateur_id);

-- ---------- 6. ALERTS ----------
CREATE TABLE alerts (
                        id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                        produit_id                  UUID          NOT NULL REFERENCES products(id),
                        statut                      VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE'
                            CHECK (statut IN ('ACTIVE', 'COMMANDEE', 'RESOLUE')),
                        date_creation               TIMESTAMPTZ   NOT NULL DEFAULT now(),
                        date_derniere_notification  TIMESTAMPTZ,
                        date_commande               TIMESTAMPTZ,
                        commande_par                UUID REFERENCES users(id),
                        fournisseur_prevu_id        UUID REFERENCES suppliers(id),
                        date_livraison_prevue       DATE,
                        date_resolution             TIMESTAMPTZ
);
CREATE UNIQUE INDEX idx_alerts_produit_ouverte
    ON alerts(produit_id)
    WHERE statut IN ('ACTIVE', 'COMMANDEE');
CREATE INDEX idx_alerts_statut ON alerts(statut);

-- ---------- 7. DEVICE TOKENS ----------
CREATE TABLE device_tokens (
                               id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                               utilisateur_id  UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                               fcm_token       VARCHAR(500)    NOT NULL UNIQUE,
                               plateforme      VARCHAR(20)     NOT NULL DEFAULT 'WEB'
                                   CHECK (plateforme IN ('IOS', 'ANDROID', 'WEB')),
                               date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now()
);
CREATE INDEX idx_device_tokens_user ON device_tokens(utilisateur_id);

-- ---------- 8. NOTIFICATION LOGS ----------
CREATE TABLE notification_logs (
                                   id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                   alerte_id       UUID          NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
                                   canal           VARCHAR(20)   NOT NULL CHECK (canal IN ('PUSH', 'EMAIL')),
                                   date_envoi      TIMESTAMPTZ   NOT NULL DEFAULT now(),
                                   succes          BOOLEAN       NOT NULL DEFAULT TRUE
);
CREATE INDEX idx_notif_logs_alerte ON notification_logs(alerte_id);

-- ---------- DONNÉES DE DÉPART ----------
INSERT INTO categories (nom) VALUES
                                 ('Consommables'),
                                 ('Pharmacie'),
                                 ('Produits de nettoyage et papiers'),
                                 ('Bureautique');

-- Consommables
INSERT INTO products (nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht)
SELECT v.nom, c.id, 'pièce', 10, 5, 0
FROM (VALUES
          ('Ten 20'),
          ('Aiguilles EMG Jaunes'),
          ('Aiguilles EMG Vertes'),
          ('Electrode de surface EMG'),
          ('Electrode patch câblée'),
          ('Aiguilles PE'),
          ('Gel EEG ECG'),
          ('Gel abrasif')
     ) AS v(nom)
         CROSS JOIN categories c
WHERE c.nom = 'Consommables';

-- Pharmacie
INSERT INTO products (nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht)
SELECT v.nom, c.id, 'pièce', 10, 5, 0
FROM (VALUES
          ('Bavette'),
          ('Gants'),
          ('Cotton'),
          ('Alcool'),
          ('Compresse'),
          ('Cebesine'),
          ('Mydricol'),
          ('Physiol'),
          ('Dorzen'),
          ('Seringues'),
          ('Calots')
     ) AS v(nom)
         CROSS JOIN categories c
WHERE c.nom = 'Pharmacie';

-- Produits de nettoyage et papiers
INSERT INTO products (nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht)
SELECT v.nom, c.id, 'pièce', 10, 5, 0
FROM (VALUES
          ('Javel'),
          ('Grésil'),
          ('Airfrech'),
          ('Désinfectant de surface'),
          ('Dinol'),
          ('Choc'),
          ('Papier Hygiénique'),
          ('Papier Essuie-tout'),
          ('Papier drap d''examen'),
          ('Savon liquide'),
          ('Lingettes'),
          ('Sac poubelle'),
          ('Goblet carton'),
          ('Goblet plastique'),
          ('Brosse pour cupule')
     ) AS v(nom)
         CROSS JOIN categories c
WHERE c.nom = 'Produits de nettoyage et papiers';

-- Bureautique
INSERT INTO products (nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht)
SELECT v.nom, c.id, 'pièce', 10, 5, 0
FROM (VALUES
          ('Toner 85 a'),
          ('Encre noire'),
          ('Encre couleur'),
          ('Rame papier'),
          ('CD'),
          ('Enveloppe'),
          ('Fiche patient'),
          ('Enveloppe pochette A3'),
          ('Carte visite'),
          ('Charge Agraffeuse'),
          ('Scotch'),
          ('Boîtes archives'),
          ('Note')
     ) AS v(nom)
         CROSS JOIN categories c
WHERE c.nom = 'Bureautique';

ALTER TABLE users ADD COLUMN reset_token VARCHAR(255);
ALTER TABLE users ADD COLUMN reset_token_expiration TIMESTAMPTZ;

CREATE TABLE patients (
                          id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                          email             VARCHAR(150),
                          prenom            VARCHAR(100) NOT NULL,
                          nom               VARCHAR(100) NOT NULL,
                          date_naissance    DATE,
                          sexe              VARCHAR(10),
                          telephone         VARCHAR(30),
                          adresse           VARCHAR(255),
                          examen_demande    VARCHAR(100),
                          medecin_traitant  VARCHAR(100),
                          clinique          VARCHAR(100),
                          date_rdv          DATE,
                          assurance         VARCHAR(100),
                          montant_paye      NUMERIC(10,2),
                          remarques         VARCHAR(500),
                          date_creation     TIMESTAMPTZ NOT NULL DEFAULT now()
);