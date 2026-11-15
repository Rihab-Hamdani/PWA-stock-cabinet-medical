--
-- PostgreSQL database dump
--

\restrict h2FNV0roVVmWnGRbonaTMKzUmaBgt2n0C5RZUHyYB1zvzWXQ0TU1lowRJTq619O

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produit_id uuid NOT NULL,
    statut character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    date_derniere_notification timestamp with time zone,
    date_commande timestamp with time zone,
    commande_par uuid,
    fournisseur_prevu_id uuid,
    date_livraison_prevue date,
    date_resolution timestamp with time zone,
    CONSTRAINT alerts_statut_check CHECK (((statut)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMMANDEE'::character varying, 'RESOLUE'::character varying])::text[])))
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(100) NOT NULL,
    purged_at timestamp with time zone,
    deleted_at timestamp with time zone
);


--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    utilisateur_id uuid NOT NULL,
    fcm_token character varying(500) NOT NULL,
    plateforme character varying(20) DEFAULT 'WEB'::character varying NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT device_tokens_plateforme_check CHECK (((plateforme)::text = ANY ((ARRAY['IOS'::character varying, 'ANDROID'::character varying, 'WEB'::character varying])::text[])))
);


--
-- Name: movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produit_id uuid NOT NULL,
    utilisateur_id uuid NOT NULL,
    type character varying(20) NOT NULL,
    quantite integer NOT NULL,
    date_mouvement date DEFAULT CURRENT_DATE NOT NULL,
    heure_mouvement time without time zone DEFAULT CURRENT_TIME NOT NULL,
    prix_unitaire_ht numeric(10,2),
    tva numeric(4,2) DEFAULT 20.00,
    prix_unitaire_ttc numeric(10,2),
    prix_total_ht numeric(10,2),
    prix_total_ttc numeric(10,2),
    fournisseur_id uuid,
    numero_facture character varying(80),
    motif character varying(255),
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT movements_quantite_check CHECK ((quantite > 0)),
    CONSTRAINT movements_type_check CHECK (((type)::text = ANY ((ARRAY['ENTREE'::character varying, 'SORTIE'::character varying])::text[])))
);


--
-- Name: notification_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alerte_id uuid NOT NULL,
    canal character varying(20) NOT NULL,
    date_envoi timestamp with time zone DEFAULT now() NOT NULL,
    succes boolean DEFAULT true NOT NULL,
    CONSTRAINT notification_logs_canal_check CHECK (((canal)::text = ANY ((ARRAY['PUSH'::character varying, 'EMAIL'::character varying])::text[])))
);


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(150),
    prenom character varying(100) NOT NULL,
    nom character varying(100) NOT NULL,
    date_naissance date,
    sexe character varying(10),
    telephone character varying(30),
    adresse character varying(255),
    examen_demande character varying(100),
    medecin_traitant character varying(100),
    clinique character varying(100),
    date_rdv date,
    assurance character varying(100),
    montant_paye numeric(10,2),
    remarques character varying(500),
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    heure_rdv time without time zone,
    statut character varying(20) DEFAULT 'PLANIFIE'::character varying NOT NULL,
    paye boolean DEFAULT false NOT NULL,
    CONSTRAINT patients_statut_check CHECK (((statut)::text = ANY ((ARRAY['PLANIFIE'::character varying, 'ARRIVE'::character varying, 'EN_CONSULTATION'::character varying, 'TERMINE'::character varying, 'ANNULE'::character varying])::text[])))
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(150) NOT NULL,
    categorie_id uuid NOT NULL,
    unite character varying(50) DEFAULT 'pièce'::character varying NOT NULL,
    quantite_actuelle integer DEFAULT 0 NOT NULL,
    seuil_alerte integer DEFAULT 5 NOT NULL,
    prix_unitaire_ht numeric(10,2) DEFAULT 0,
    date_peremption date,
    numero_lot character varying(80),
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT products_quantite_actuelle_check CHECK ((quantite_actuelle >= 0)),
    CONSTRAINT products_seuil_alerte_check CHECK ((seuil_alerte >= 0))
);


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(150) NOT NULL,
    telephone character varying(30),
    email character varying(150),
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    mot_de_passe character varying(255) NOT NULL,
    telephone character varying(30),
    role character varying(20) DEFAULT 'SECRETAIRE'::character varying NOT NULL,
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    reset_token character varying(255),
    reset_token_expiration timestamp with time zone,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['MEDECIN'::character varying, 'SECRETAIRE'::character varying])::text[])))
);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_nom_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_nom_key UNIQUE (nom);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_fcm_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_fcm_token_key UNIQUE (fcm_token);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: movements movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_pkey PRIMARY KEY (id);


--
-- Name: notification_logs notification_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_alerts_produit_ouverte; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_alerts_produit_ouverte ON public.alerts USING btree (produit_id) WHERE ((statut)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMMANDEE'::character varying])::text[]));


--
-- Name: idx_alerts_statut; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerts_statut ON public.alerts USING btree (statut);


--
-- Name: idx_device_tokens_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_tokens_user ON public.device_tokens USING btree (utilisateur_id);


--
-- Name: idx_movements_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_date ON public.movements USING btree (date_mouvement);


--
-- Name: idx_movements_produit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_produit ON public.movements USING btree (produit_id);


--
-- Name: idx_movements_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movements_user ON public.movements USING btree (utilisateur_id);


--
-- Name: idx_notif_logs_alerte; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notif_logs_alerte ON public.notification_logs USING btree (alerte_id);


--
-- Name: idx_patients_date_rdv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patients_date_rdv ON public.patients USING btree (date_rdv);


--
-- Name: idx_products_actif; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_actif ON public.products USING btree (actif);


--
-- Name: idx_products_categorie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_categorie ON public.products USING btree (categorie_id);


--
-- Name: alerts alerts_commande_par_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_commande_par_fkey FOREIGN KEY (commande_par) REFERENCES public.users(id);


--
-- Name: alerts alerts_fournisseur_prevu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_fournisseur_prevu_id_fkey FOREIGN KEY (fournisseur_prevu_id) REFERENCES public.suppliers(id);


--
-- Name: alerts alerts_produit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_produit_id_fkey FOREIGN KEY (produit_id) REFERENCES public.products(id);


--
-- Name: device_tokens device_tokens_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: movements movements_fournisseur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_fournisseur_id_fkey FOREIGN KEY (fournisseur_id) REFERENCES public.suppliers(id);


--
-- Name: movements movements_produit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_produit_id_fkey FOREIGN KEY (produit_id) REFERENCES public.products(id);


--
-- Name: movements movements_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.users(id);


--
-- Name: notification_logs notification_logs_alerte_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_alerte_id_fkey FOREIGN KEY (alerte_id) REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: products products_categorie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_categorie_id_fkey FOREIGN KEY (categorie_id) REFERENCES public.categories(id);


--
-- PostgreSQL database dump complete
--

\unrestrict h2FNV0roVVmWnGRbonaTMKzUmaBgt2n0C5RZUHyYB1zvzWXQ0TU1lowRJTq619O

