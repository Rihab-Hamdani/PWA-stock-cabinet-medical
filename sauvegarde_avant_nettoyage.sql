--
-- PostgreSQL database dump
--

\restrict lTLYBtLd6cusYT4oYqGMTSTlwJyEK5KsHRFp6NRPeGFqhFKU3KuBnfvcgltYzue

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.alerts OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(100) NOT NULL,
    purged_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    utilisateur_id uuid NOT NULL,
    fcm_token character varying(500) NOT NULL,
    plateforme character varying(20) DEFAULT 'WEB'::character varying NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT device_tokens_plateforme_check CHECK (((plateforme)::text = ANY ((ARRAY['IOS'::character varying, 'ANDROID'::character varying, 'WEB'::character varying])::text[])))
);


ALTER TABLE public.device_tokens OWNER TO postgres;

--
-- Name: movements; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.movements OWNER TO postgres;

--
-- Name: notification_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alerte_id uuid NOT NULL,
    canal character varying(20) NOT NULL,
    date_envoi timestamp with time zone DEFAULT now() NOT NULL,
    succes boolean DEFAULT true NOT NULL,
    CONSTRAINT notification_logs_canal_check CHECK (((canal)::text = ANY ((ARRAY['PUSH'::character varying, 'EMAIL'::character varying])::text[])))
);


ALTER TABLE public.notification_logs OWNER TO postgres;

--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_backup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products_backup (
    id uuid,
    nom character varying(150),
    categorie_id uuid,
    unite character varying(50),
    quantite_actuelle integer,
    seuil_alerte integer,
    prix_unitaire_ht numeric(10,2),
    date_peremption date,
    numero_lot character varying(80),
    actif boolean,
    date_creation timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.products_backup OWNER TO postgres;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom character varying(150) NOT NULL,
    telephone character varying(30),
    email character varying(150),
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts (id, produit_id, statut, date_creation, date_derniere_notification, date_commande, commande_par, fournisseur_prevu_id, date_livraison_prevue, date_resolution) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, nom, purged_at, deleted_at) FROM stdin;
18155e6c-2cfb-459f-b5b7-788e0099adb3	Consommables	\N	\N
7037a957-46df-4daa-9fc7-cf80eb99e278	Pharmacie	\N	\N
39671532-aaf8-4e70-a9ab-8390e7ca763b	Produits de nettoyage et papiers	\N	\N
2e893096-d8da-447d-ae9c-ab380bb87c33	Bureautique	\N	\N
94c7c02a-8a11-4fd8-8b98-0d89db1b965b	cat [supprimée 1791158579392]	2026-10-05 01:02:59.392819+01	2026-10-05 00:49:14.697696+01
23b5d129-8549-4209-bc9a-8387d74e7998	abdou [supprimée 1791158582669]	2026-10-05 01:03:02.669483+01	2026-10-05 00:49:11.606637+01
d754caae-3f2c-44a5-a14d-fb93a553c1b2	jamila [supprimée 1791158586050]	2026-10-05 01:03:06.05002+01	2026-10-05 00:07:55.206246+01
928d0a8b-82f8-4acd-9fd2-6ff59fc2d5a2	__probe__ [supprimée 1791159915770]	2026-10-05 01:25:15.770535+01	2026-10-04 23:19:49.676658+01
2fcf9895-8635-48b1-9702-3c8a8880460d	Hamdani [supprimée 1791159921400]	2026-10-05 01:25:21.400202+01	2026-10-04 15:25:04.10067+01
f7b858af-10ca-4b2f-856b-e91450274fac	hamdani  [supprimée 1791159951768]	2026-10-05 01:25:51.76853+01	2026-10-05 01:25:44.689704+01
eb18ac27-d366-4445-ae8d-f2bb9d1a78fb	rihab [supprimée 1791159953913]	2026-10-05 01:25:53.913392+01	2026-10-04 15:25:10.076097+01
09c3b16e-ad5b-470b-902a-56434730617d	cat [supprimée 1791240256785]	2026-10-05 23:44:16.785573+01	2026-10-05 23:44:12.323308+01
8141a178-8e73-41c9-9ccd-b09ef5a54a36	houma [supprimée 1791405920208]	2026-10-07 21:45:20.208471+01	2026-10-07 21:45:14.147953+01
64fd9772-d94a-4f49-897c-4625a727e58c	Famille [supprimée 1791574238961]	2026-10-09 20:30:38.961606+01	2026-10-09 20:30:34.34985+01
f398caef-009d-428f-b6fb-ce122d877700	Hello [supprimée 1791578480721]	2026-10-09 21:41:20.721778+01	2026-10-09 21:41:12.793915+01
24cc8da8-056e-4393-8578-41e30323e94e	Cat1 [supprimée 1792927803126]	2026-10-25 12:30:03.126538+01	2026-10-25 12:29:58.094747+01
aac3020c-ce7f-4a4e-9ad5-668114f1c216	Cat1 [supprimée 1794271075501]	2026-11-10 01:37:55.501747+01	2026-11-10 01:37:51.394969+01
eab4529f-c15f-445a-871f-70e43800e989	cat1 	\N	2026-11-15 08:55:17.930156+01
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_tokens (id, utilisateur_id, fcm_token, plateforme, date_creation) FROM stdin;
\.


--
-- Data for Name: movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movements (id, produit_id, utilisateur_id, type, quantite, date_mouvement, heure_mouvement, prix_unitaire_ht, tva, prix_unitaire_ttc, prix_total_ht, prix_total_ttc, fournisseur_id, numero_facture, motif, date_creation) FROM stdin;
c4ce5389-54fb-49ed-ba70-be73f4a7ecba	cae1f6fa-99d8-44e5-93c6-986126fb1478	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:27:40.303	0.00	\N	\N	0.00	\N	\N	\N	\N	2026-10-25 12:27:40.303059+01
e2e8e46b-d9f0-4e2d-9f01-0f863ddc947f	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	ENTREE	10	2026-10-25	12:28:37.207	15.00	20.00	18.00	150.00	180.00	69c194ff-0af3-43af-9185-101dc335ea06	F1226	\N	2026-10-25 12:28:37.20735+01
ebc382c2-3d7d-40ea-99ab-d13096a0d0bb	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:28:45.049	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:28:45.049223+01
29ae02c0-4629-426a-b5f4-085edbd70084	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:28:48.101	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:28:48.100641+01
6ee6ce11-77d1-4ae7-90b6-c1f54fe6d9a9	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:28:48.836	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:28:48.835592+01
9050cd5f-9c68-451f-bdd2-3f6e2a2f0c6a	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:28:49.469	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:28:49.468543+01
0c91d910-9e5f-45d4-b2c7-825bb33a6281	47571295-9883-4a97-9d40-f37c31ba713d	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	ENTREE	3	2026-10-25	12:29:30.497	20.00	20.00	24.00	60.00	72.00	29e777f9-8e46-4971-8fe5-02649778bc20	\N	\N	2026-10-25 12:29:30.496804+01
a2800762-419b-46c7-a5ba-b446a688b77e	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:33.015	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:33.014898+01
bc23ee1c-d6e6-4cf3-8c5e-0724918c5af7	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:33.337	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:33.337214+01
21a4b358-049c-43c6-80ba-e1cefa97c813	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:34.488	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:34.48777+01
d7897e88-aaa0-43fb-816c-28350b562640	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:35.906	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:35.905631+01
a15f2729-219c-4460-8fff-08aed1fd35db	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:36.527	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:36.527305+01
29960620-dc2c-498a-bc44-de195b49d9b1	950d8e5b-efde-4780-b750-6ce367564ca0	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-10-25	12:29:37.104	15.00	\N	\N	15.00	\N	\N	\N	\N	2026-10-25 12:29:37.103502+01
6832f079-5be5-44e9-91c0-1bcb48afe1b2	332dc9aa-1e36-4198-9b92-2bcfa2e19dd6	3e4d8150-2271-4e98-90f6-e4641b2756fd	ENTREE	9	2026-10-25	13:34:32.897	50.00	20.00	60.00	450.00	540.00	69c194ff-0af3-43af-9185-101dc335ea06	\N	\N	2026-10-25 13:34:32.897077+01
984c6fd8-aa8f-4403-bf21-cff615fefed2	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	ENTREE	15	2026-11-10	01:44:35.217	12.00	20.00	14.40	180.00	216.00	69c194ff-0af3-43af-9185-101dc335ea06	\N	\N	2026-11-10 01:44:35.217314+01
ed12cc6a-f552-4935-9b2c-08f116a3a699	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:46.66	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:46.659731+01
1fe6c9ce-39d2-4787-bc68-01d748c794dc	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:47.233	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:47.232753+01
0c850e6c-6fe4-4091-b51a-fb7eefb2c98c	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:47.338	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:47.337759+01
ff00116d-74bf-4072-86c7-b82671f477bb	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:47.628	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:47.627753+01
e49ee0e7-be40-4543-a6f5-3fbe7612362d	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:47.734	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:47.733756+01
49c6225c-808c-4441-8cb0-bb851ef7ee8b	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:48.383	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:48.382762+01
007b153a-ab8f-457f-9731-1fb992349098	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:48.763	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:48.762676+01
992f1427-f9e4-4f00-ac01-fac5141bbae6	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:48.865	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:48.865358+01
c0347162-7ad8-4b90-a10b-aefd4a7a5723	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:49.309	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:49.309026+01
211921f3-cb10-4b77-aa4e-34f871b3f2f7	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:50.08	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:50.079858+01
b7b6ca62-96c2-4320-9eb0-a1a8ffcb2dd7	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:50.526	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:50.525696+01
48eb9516-f225-4538-85a2-342bdc29cb8b	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:51.085	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:51.084594+01
0ca5fb32-0717-49e8-9acd-1fc25e16601b	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:44:52.469	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:44:52.469333+01
ecd4cb33-6f21-45cc-9387-46382322a90a	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:45:05.752	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:45:05.751701+01
db506d5a-d472-469f-9e97-5cd0c288669f	e0531b69-b609-42aa-a602-c7675e1b60d1	8f935607-e16a-4ed1-b8b0-84bedb5ac34f	SORTIE	1	2026-11-10	01:45:06.213	12.00	\N	\N	12.00	\N	\N	\N	\N	2026-11-10 01:45:06.212918+01
\.


--
-- Data for Name: notification_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_logs (id, alerte_id, canal, date_envoi, succes) FROM stdin;
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, email, prenom, nom, date_naissance, sexe, telephone, adresse, examen_demande, medecin_traitant, clinique, date_rdv, assurance, montant_paye, remarques, date_creation, heure_rdv, statut, paye) FROM stdin;
c7b0e952-e153-4cd3-b0aa-da5b29045d1b	rihabhamdani05@gmail.com	Rihab 	Hamdani	2005-05-03	Féminin	95058844 | 974565123232	Libie	PEV	Dr Manel	\N	2026-10-02	Non assuré	250.00	\N	2026-10-02 17:59:31.170787+01	\N	PLANIFIE	t
d8bcaf29-aa0c-4a55-bf20-a274d134cecd	rihab.hamdani@ieee.org	Rihab	Hamdani	2005-03-05	Masculin	95058844	Djerba Houmt Souk	PES	Dr Dammak	\N	2024-11-23	Assurance	500.00	\N	2026-10-07 21:15:08.96298+01	\N	PLANIFIE	t
3330cbe5-96e8-421e-a800-0ab373e92d18	rihab@gmial.co	bonjour	coucou	2026-10-23	Féminin	222222222	Tataouine	EMG avec test myasthénie	Dr Bergaoui	Echifa	2026-10-07	CNAM	750.00	\N	2026-10-07 21:16:44.949085+01	\N	PLANIFIE	t
98bb36e5-a824-47af-8dd3-3fbfbd5879fc	rihaban@gmail.com	Hamda	Pat1	2014-08-01	Féminin	1234578	Médenine	PEA	Dr Bergaoui	La Douce	2026-10-25	Non assuré	250.00	\N	2026-10-25 12:31:01.857412+01	\N	PLANIFIE	t
bc294276-9fcd-4c8a-8105-351ca7e8ad0a	bdjsks	Rih 	Hamd	2026-10-23	Féminin	23484040	Médenine	PES	Dr Bergaoui	La Douce	2026-10-25	CNAM	1239.00	\N	2026-10-25 13:10:11.272563+01	\N	PLANIFIE	t
7634ac99-e402-4822-86f3-c17cb7fcc5ef	hamdanirihab5@gmail.com	Rihab	Hamdani	2026-10-31	\N	95058844	Tataouine	PEA	Dr Manel	\N	2026-11-13	\N	0.00	\N	2026-11-10 01:37:34.117999+01	\N	PLANIFIE	f
b97ab343-6d56-47fe-8598-a8ea36e2e302	rihab@gmial.co	bonjour	coucou	2026-10-23	Féminin	2525525	Tataouine	Test cutané PVN	Dr Dammak	Echifa	2026-11-06	\N	0.00	\N	2026-11-14 23:21:44.511913+01	00:21:00	PLANIFIE	f
f0601980-53d3-461a-87f5-5df4cf8e8f44	hamdanirihab5@gmail.com	Rihab	Hamdani	2025-01-30	Féminin	95058844	Libye	EEG de veille	Dr Bergaoui	\N	2026-11-13	\N	0.00	\N	2026-11-10 01:36:18.733331+01	15:35:00	PLANIFIE	f
fc5c6405-c764-4170-b74c-4d6aec7f61b6	hamdanirihab5@gmail.com	Rihab	Hamdani	2026-10-31	Masculin	95058844	Médenine	Test cutané PVN	Dr Bergaoui	Centre Arij	2026-11-14	CNAM	0.00	\N	2026-11-14 22:53:25.92977+01	01:58:00	PLANIFIE	t
d7565666-73b8-423b-9cb1-a56271031ed6	hamd	pat1	rihab	\N	Féminin	\N	\N	\N	\N	\N	2026-11-15	\N	0.00	\N	2026-11-15 08:52:47.235482+01	\N	PLANIFIE	f
35562851-2ec8-4b1f-92f3-b08d115efdc9	rihabhamdani05@gamil.com	hhhh	hhhhhhh	2042-07-02	\N	95058844	Djerba Houmt Souk	EEG de sommeil	Dr Bergaoui	La Douce	2026-11-15	\N	123.00	\N	2026-11-14 02:21:34.089982+01	02:30:00	TERMINE	t
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht, date_peremption, numero_lot, actif, date_creation, deleted_at) FROM stdin;
a425d726-9e67-45e7-9d14-2fcb640b1b0a	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
4ae99a05-335e-4b12-b37b-951b49c118b0	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
3036f488-db16-4552-8c44-09f7ec31236c	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
e2a57fbe-05ce-44c8-9137-2dd8edac904b	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
0c75afe0-87d5-48e2-8112-bfade99d7e8e	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
933f035b-088b-4140-8cef-673cf235ba05	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
5cabfd37-e5d1-4c84-9d9f-beeb268e5c8b	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
835ae97b-2c87-4721-bca5-8a26c23142c1	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
4ef9f75d-9fe6-483c-9b0c-0fe1b3bca97c	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
67749606-f955-40d7-be79-798fbe5f1c41	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
4397f96e-6777-4d86-85b7-af3cb57bf3a7	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
aab2b54d-5a34-429b-8592-62c1fa142ab3	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
782ec6bb-8394-4c30-b53a-99ef785af4cc	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
1d278c31-0bdb-49b9-970c-df06f8b53dc7	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
7765e014-92c2-4d97-978e-88c5cc046233	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
c02d5dca-d3ba-40a7-a3a4-2173f0764dc3	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
2db4b267-7aca-4585-850b-711d4f9f5bf0	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
09050701-0b1a-4228-833b-233550e77536	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
126bf975-4870-4ceb-a715-b4116070a3c8	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
785247a7-de42-4541-b2c7-32a140b843bf	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
538c8d1b-f4d5-475e-84d6-8f3aeafd9d83	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
5fe63d8a-a833-4240-9984-5260508abcd9	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
2564a078-30c8-4135-8213-bd5d3ed59035	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
238bd42a-0679-43af-aa3a-a214dce7839b	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
3df9309e-9c2f-4742-bd9b-e423e4d07fff	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
24119285-a597-47b5-8e6a-15653dc664ad	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
8b50bded-c3e5-4a26-988e-bfe8bc7f1adb	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
b8a015f6-209f-4ca4-9781-27d9bc085a11	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
71433fed-8763-4fea-b4b6-63956dc5b998	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
e61e735b-06da-4a13-82fb-d5fab72249a1	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
7a74b7f6-3a8e-4a35-b190-0cad7d318f2b	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
3e86dcb8-41e8-48de-9254-78d6739806d2	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
6f9484d2-09a4-4e88-a132-2a9b11955654	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
728419ed-d393-4815-bed7-1b0c29ad814e	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
df2d2b73-dd54-4e4f-a019-fef31e22d4f2	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
bf593cac-d7c4-467e-a08a-5bc4a82615c1	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
26b6f47b-4f32-45f8-88b6-f48ed45dca98	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
553f3ea6-e1c3-420a-af2b-32f40aa71f81	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
a87bd709-d00b-42ae-98eb-95c277f65562	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
645fad04-e571-47d7-ae21-2d27be0b6e43	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
3e9752f1-52bf-44ee-aabc-fbd612966c52	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
f0497daa-fd29-420a-9880-163ac2c76f65	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
ecf9fde1-dd35-42dd-8ba4-e25e1f8e38d2	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
afb86f04-ed3f-4fb8-b891-f38dbd64db08	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
61afe0e3-4eb3-47bb-82c3-f5b985c3575c	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	12	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
1dec08f9-0a2f-4f4f-9a7d-c3a40772783f	prod1	09c3b16e-ad5b-470b-902a-56434730617d	pièce	5	1	0.00	2026-10-18	\N	f	2026-10-05 23:43:11.366708+01	2026-10-05 23:44:12.323308+01
92615b03-d76e-4332-a9d8-3d2573c1047d	Hams	64fd9772-d94a-4f49-897c-4625a727e58c	pièce	6	5	4.00	\N	\N	f	2026-10-09 20:30:03.559539+01	2026-10-09 20:30:34.34985+01
cae1f6fa-99d8-44e5-93c6-986126fb1478	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	9	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
950d8e5b-efde-4780-b750-6ce367564ca0	Prod1	24cc8da8-056e-4393-8578-41e30323e94e	pièces	0	6	15.00	\N	\N	f	2026-10-25 12:28:37.203303+01	\N
e0531b69-b609-42aa-a602-c7675e1b60d1	Prod1 	eab4529f-c15f-445a-871f-70e43800e989	pièce	0	3	12.00	\N	\N	f	2026-11-10 01:44:35.169404+01	\N
e13a2487-15c7-49a1-99e1-b9634aa3481c	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
0cd63a85-35aa-4d62-a238-7185fbb1eb29	prod1	8141a178-8e73-41c9-9ccd-b09ef5a54a36	pièce	50	5	10.00	\N	\N	f	2026-10-07 21:17:43.650989+01	2026-10-07 21:45:14.147953+01
a79dbfe1-1b64-4aeb-a6eb-ed90a4675b65	from	f398caef-009d-428f-b6fb-ce122d877700	pièce	6	5	2.00	\N	\N	f	2026-10-09 20:40:45.974782+01	2026-10-09 21:41:12.793915+01
47571295-9883-4a97-9d40-f37c31ba713d	Prod 2	24cc8da8-056e-4393-8578-41e30323e94e	Bouteille 	3	2	0.00	\N	\N	f	2026-10-25 12:29:30.437362+01	2026-10-25 12:29:58.094747+01
ebc95685-0531-452a-b662-bd4cdd3a0344	from 	f398caef-009d-428f-b6fb-ce122d877700	pièce	0	5	0.00	\N	\N	f	2026-10-09 21:40:45.935313+01	\N
332dc9aa-1e36-4198-9b92-2bcfa2e19dd6	Prod1	aac3020c-ce7f-4a4e-9ad5-668114f1c216	pièce	11	5	12.00	\N	\N	f	2026-10-25 13:10:38.411681+01	2026-11-10 01:37:51.394969+01
1a24fafd-2a29-4002-9828-26e24fdaebb8	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
035f3f6a-4172-4873-8888-a607f57d3ff4	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
4d1f7484-5632-41fb-ad22-7d9c134c60e5	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	8	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
5284ee53-a0f6-4731-b543-2900073e912e	hamdani	eb18ac27-d366-4445-ae8d-f2bb9d1a78fb	boite 	3	2	15.00	\N	\N	f	2026-09-27 22:26:42.484686+01	\N
211b0bfe-f4fc-4e29-94e6-7f1e26f6529d	Rihab 	2fcf9895-8635-48b1-9702-3c8a8880460d	paquet 	0	1	0.00	\N	\N	f	2026-10-02 17:54:46.936345+01	\N
29852bf1-a0df-4e19-bee4-9116213e793c	hiba 	2fcf9895-8635-48b1-9702-3c8a8880460d	pièce	5	5	0.00	\N	\N	f	2026-10-02 17:55:56.630005+01	\N
5b53bdca-9f3c-4587-a5de-60584b68477f	hamdnai 	eb18ac27-d366-4445-ae8d-f2bb9d1a78fb	pièce	10	5	15.00	2027-05-03	\N	f	2026-09-27 23:40:09.718618+01	2026-10-04 15:25:10.076097+01
2de79e26-745d-4edf-8e34-5f3445125d4a	__probe__	928d0a8b-82f8-4acd-9fd2-6ff59fc2d5a2	u	0	0	0.00	\N	\N	f	2026-10-04 13:45:37.003164+01	2026-10-04 23:19:49.676658+01
6f84beb4-d003-4424-8333-b077fb38b52c	Rihab	d754caae-3f2c-44a5-a14d-fb93a553c1b2	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:07:47.506933+01	2026-10-05 00:07:55.206246+01
ae399c49-536d-434e-b7d3-a5d7a571ffc7	r	23b5d129-8549-4209-bc9a-8387d74e7998	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:08:09.799408+01	2026-10-05 00:49:11.606637+01
21da7fcb-70a3-4446-81ed-a326a3ab0948	prod	94c7c02a-8a11-4fd8-8b98-0d89db1b965b	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:33:11.078814+01	2026-10-05 00:49:14.697696+01
c53f6722-f80a-461c-ba0d-80080d14923f	rihab 	f7b858af-10ca-4b2f-856b-e91450274fac	pièce	0	5	0.00	\N	\N	f	2026-10-05 01:25:36.800886+01	2026-10-05 01:25:44.689704+01
39786dc8-c499-4c5c-8f15-c54c0cacb85f	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
63d9e769-4b3d-4490-8c4b-d1719329ee47	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
41b73ee0-e29e-4d27-bb52-93026ce84017	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
798f540a-ffdf-4166-9db1-49499650773f	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
d6488c9f-9334-4a96-a649-0ad5cbd97ff4	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
123b7db8-33c9-4b03-b241-f9dad1dc943d	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
e3266447-c43c-4ea6-a4c2-b3a3b8f0c42b	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.312211+01	\N
64f99efe-a642-4495-973f-a3a19a196c68	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
dca7aca9-6e07-4c76-a88e-39f07f1837a5	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
908c4262-759c-4089-ae5d-f627fbbbff3e	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
7ce66b8c-e4c0-46d2-a50f-e1493a7e9993	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
ee9e921e-b73c-41a3-98e8-e9c19757dfd8	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
ecc18cfe-bc99-4c06-a65e-dca5fd275476	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
6dbb8230-2436-4979-ae62-b119cf2c4a26	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
cba6b49e-3517-444d-a548-45aedfad1efc	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
64734c5f-ea61-44fc-8e7f-1def67a5bdcb	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
e629318d-4383-432f-9432-97c2cd40a584	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
2b9c8e8f-5abd-425f-86fb-fcbf0cf2a097	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.31993+01	\N
5ed86b5b-1582-47a1-8c64-e4f31d42085f	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
fcb29bce-e6fb-4837-9926-31d1bb9adfee	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
54f54bac-5e52-4a54-8faf-da9c613d3e1a	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
b9e75e8e-8718-4a63-bfc8-47d89790dbeb	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
0a7d2888-a8e3-4943-9002-56d7afe97178	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
2bca0b92-18ca-4fb0-ab58-222ac7565ba7	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
343f2f9e-10b7-44fe-971c-b453a8c32314	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
ad50586b-c7a3-4f88-826f-a0c19a839e22	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
9035d960-3a59-4529-99d8-6ac0d4c7cf97	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
dcc06130-dd80-4ee2-a500-fde395e08c3a	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
c68f8834-ee5a-4d85-8a97-71430936477c	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
ec6de852-e89e-468a-9c6e-0c74fe330d93	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
c02f434b-04d9-412e-baaa-a2709a668903	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
401be011-48a8-4ed2-bb76-dc0752c9a2f4	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
b3a6746c-0422-4e9a-903c-34e5aff0a795	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.328076+01	\N
da8ba5d8-8921-4cc6-b4c7-6ea3411591d3	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
672357c3-b6c4-4ff7-8127-5d2cf823d8fe	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
bdf75992-c7fa-4495-bf00-8ef9a172e9af	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
46f12e51-f20b-4a4c-ba78-1708dea275fe	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
024624c3-08c1-4f44-83f0-a55b2f3c715b	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
6359fe72-cac0-4030-84fa-dd66139bcd78	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
4af25d08-7feb-4997-b13b-19349868e24b	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
df7889cc-bf30-459b-92e2-5e3c107854da	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
a4dff494-1f36-478d-9d03-1b9ab40d3c75	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
3c651c07-d42c-4716-bedf-275495018744	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
97809d5c-df50-4a63-8968-d575646369f6	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
380b19d2-2433-40ef-b355-4924e173e954	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
5ae67f59-4a0c-481e-9dcd-87dfeeb31691	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:14.335394+01	\N
3e3756e4-adc7-4d76-85be-e89ed430d4b0	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
5d6f8932-4a4d-47a3-90a6-2de42f0b080d	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
90bc8bd3-8fe3-453d-8d6b-90160f17f9d3	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
801207c4-ea23-402a-9c90-78053fd5ff93	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
bd9569aa-6135-4cfc-a464-d6f1aa5f779a	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
9c6d77bc-7bbe-4741-b7f9-05d1d2719fdb	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
809c8f59-c267-4200-bf7a-dd45868ab4d8	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
8a3df9b5-7312-4025-833a-03e1289751a1	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.301936+01	\N
8acf6533-a956-42aa-b6a9-e1f48eeeae53	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
633d1717-6c36-4385-b57a-a78e3547bd3f	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
b5ff5900-4137-4301-ae67-375f2953b1fa	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
d867a451-e939-49ac-891f-a0658abbf7cd	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
9064fa96-647a-4207-8c95-837aa8fff0f4	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
433d1670-8510-43ff-aab6-ffb30e21aac6	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
7615fe58-336a-453d-bead-9b7efe8b5ef8	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
d5b93c55-2608-460f-b524-28bf9e76f70d	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
3d4be45a-f09c-483e-bea6-4d8938b24791	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
406eb81d-d322-45c8-adff-97de0e1521b2	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
7f1a4ea3-2389-4658-bd00-ae74a26488b5	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.307447+01	\N
c199e90a-e6a2-43c2-8c6b-c384436e8ef7	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
9abc1c7b-9412-4dda-8ab8-6925da6420ff	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
f915867b-7ae1-4f65-8786-efc8a8cab50b	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
34bcb842-c82b-433b-994e-9a66613361dc	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
780b1497-a263-4079-abee-73dcb9741a90	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
30b426ee-33e8-4c02-9979-2c00a53cbb40	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
4d419d14-6118-4aae-bef7-5092c2d1d430	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
799d324c-b76c-4cb9-96b8-baa7fa3bfb85	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
4c4aff76-8cf2-4fd7-b862-670b2461a554	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
978d4d75-ff93-4a0c-b3fb-098003652d9c	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
1dc2f1c6-e0da-4f24-ae4e-a18ed87c6964	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
c1485b33-b7e7-49a5-8a97-70853ae630b1	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
cdcc3fec-a037-40b8-b1d7-90fd1010ad83	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
6c26000f-4d48-47b7-b0a1-5944b22014d8	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
d6e304c5-1bf9-43ba-af22-3a3c68e209cb	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.314196+01	\N
93634e96-f620-47ff-91db-2210fb9e7235	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
d2d96d93-fa42-4d42-bd4f-b85c01496d14	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
5225e8e9-885f-4bb5-abc4-8f79f26e9026	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
519b5ea4-5d5a-42c4-b358-db72d0903eb2	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
39cf3e49-3aa7-44fb-953e-8f6683c9cf06	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
cec36251-7ca4-40db-ab85-48214be86fda	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
2f28844f-712f-44a6-b7cf-f2d20731f0a2	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
8996d4e1-7c77-4ea6-be65-81222db5d23e	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
e0636659-1723-4202-ba07-fe0f49bff2cf	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
7c4e54be-db9e-4288-86fa-eb8a0ccf442d	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
c298bc51-6481-4323-b6b3-8384e8c081c6	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
bbf39098-6880-4958-b278-6a9275aa9ce2	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
573259dc-40de-4804-9cf7-3402e9798e0f	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:17.320208+01	\N
f2dff041-f4c5-4e44-b51d-06c0f5ffbf06	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
8cf41363-ae68-47ee-ac65-3c03f367ad41	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
03795fef-d1e2-4c7e-b08e-79cbca361e43	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
f1fb33a7-294e-4355-a150-e2dc21f563da	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
7ce0d40b-22bb-4e52-bbf4-e2a7f022b19c	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
de1c52ae-ff9b-4660-a46c-2cbcd430a308	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
4f229a2b-b156-4034-b3b2-9f71958f27a2	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:33.780769+01	\N
b3b1d4ad-07fc-46b2-8bf9-79d84e3d5172	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
87eff567-eb49-45fa-8956-efda0a86f0ac	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
d820130e-a78a-4759-9326-11f879a36c7d	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
6016c5f5-e138-40f8-b3b4-2548be431e15	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
6c186e98-1e82-4842-b469-3f34248dabeb	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
f87011f2-1ac6-4275-8e97-6c5809b1e308	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
6c00bc62-46c6-4ff1-8dc6-0131d634fa52	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
aa3a34a7-72df-487c-b31f-b5c6e315eb04	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:51.055364+01	\N
d376f1a5-65ba-4833-ab66-dc928faeefc2	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
0ec57d8b-e4cb-4b9c-a4f9-e0b3a6d64a58	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
74a325a0-842e-401c-ab08-5861b17e38b9	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
8d2749a8-7f78-41e0-923b-7ef51ec3ab20	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
96f43d95-f893-408c-a7dc-225951cb8a5e	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
4b914c2e-4c7e-48da-8fa0-271cfdfeb8ea	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
bfff8d90-41ac-48d5-9ced-f2d6c4d4ad44	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
84de6569-0d91-44c1-8ab4-f1b17346c98c	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:58:58.967327+01	\N
947d669b-fb77-4dd3-97a4-00b3e336a4e3	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
6679514d-95a2-403b-967f-6d4159567660	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
6e9ef9f6-c94f-4cf4-971c-797072bd980d	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
280ae3bf-afa7-4e7f-babd-64669948b090	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
113cc078-8f58-4276-aba6-bff45456688a	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
8e502401-9ad9-4b0a-9dfc-983fc46e2fb4	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
a3570be1-bfa5-46e1-bd32-62176dde0ee2	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
fc2cca13-ccbb-482b-bcf4-6c80bc52aa7c	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
3a90dde6-2004-43cc-a64a-80d291bba6d5	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
91c1f0f0-825a-432c-932c-677bb8e2f134	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
e3ff4ef1-b254-4faa-9b5a-db7b29f3b6ed	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:05.790406+01	\N
26465690-68b3-4da2-bc5e-ea3d23d45f28	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
eefabb73-5a9e-4568-bd5a-c9714dfd6ab1	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
63ce88d0-8a1c-41bc-a931-8d745eb85812	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
2d0e4914-8cfc-49d8-ba05-b8dd9147bc36	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
bc002e6f-6845-4754-8f6d-c9cab68b0c7d	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
fdd5fc9f-e167-40ae-8bc0-9824c2ae5236	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
fc75509c-1672-4060-9c96-f771e57065df	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
31bd90ed-9f11-4ca2-b40d-74dc7bdf2f7b	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
37ac808e-1e52-4b58-b229-9b624fe74126	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
361ce975-138c-49c2-a341-58980b8cee5c	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
e6a4535a-a9d6-4666-a6bb-d1c458ca15ea	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
6ac4de1f-ff3d-4eee-b4ad-9b38f86e295e	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
eec107df-fb74-4654-a9ea-db45d403c9be	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
3a8e0e88-dae9-4172-89ce-463befb4402a	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
98cece58-81a4-4998-b6e8-475b573b7647	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
01493711-b72a-4efa-a15d-0c6bc9be07b8	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
0adf8d7f-cb85-453c-8c9a-87326313588f	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
d492ca30-adb4-4ee1-888d-6bc3d5f81be7	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
e4bbb40d-f386-4a68-a50b-15178bd9d802	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
24423a40-cefd-4470-9178-1f6b84c39ae9	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
4993f2ec-0113-4d98-a893-98fdb58a3a68	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
c18db793-be25-4edc-a344-cd4e058ec8d8	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
8a147a6e-abac-4145-8f2b-2cf1fadf5cb9	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
11016ed9-e24a-469f-9c31-b6a448f3070d	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
7ca191fb-529d-4a6d-92b6-e5a9b82fe52f	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:14.78468+01	\N
9536361a-b050-4182-a8a8-0d89c9b430fe	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
7e24c8bc-57b6-4b89-8fa4-09cc0722bc08	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
c41b6ff6-1241-4df9-a346-ffeaee9d3930	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
6ba252e4-3abd-4405-b82b-b1c269965b89	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
3702b2c1-13b8-4632-944c-1d9ab1a89a17	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
79f34965-1cea-4f4b-8adb-746fe335a99b	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
40738519-fd00-4744-8522-90cd04a0a513	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
a9ecafb6-4b6b-4f0a-b7ee-12ec00e2da38	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
cdc19b29-d2a5-47b2-989f-ad694aac9cfe	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
57af31da-949e-4029-8e59-ccfe8a90a2ed	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
2dd4fcef-ba5b-4929-bf81-2f8ffdcf9688	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
e81012ad-bc44-4d19-9a69-0169c3e7f9a5	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
dbf71b89-0688-4a36-b78f-20c4a412cd22	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
6b35edef-a317-4591-91d6-361051bddf40	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
70ab6a5c-ad38-4f6a-bf20-4598756af9f7	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:17.612168+01	\N
92dd5fd5-9c26-4350-abdb-deb8d3a3cf55	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
e5e305f4-e237-429d-ae39-7a2f4c44ae61	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
0d42514a-0270-4029-be01-9170c08db158	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
f58bb119-b1d1-4fb4-9492-5a2dc3158818	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
5090b6ad-3f08-448c-a880-e5467bdcfb8f	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
818578cd-c937-41e9-a860-0741c55c49ee	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
de31204c-f9f8-4b01-a458-872d2dd08074	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
984727a1-db5c-4517-8ef5-1c855dcb6d87	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
63e23c9d-f050-4fcc-9b4d-3650d204fb6a	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
53ac4471-c513-498f-a990-1b5e8dfc7146	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
9436dfa2-a5e6-41fc-9cf6-e56b3aa56f92	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
477729bb-32d5-4a41-99f2-49326c9e51db	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:22.305629+01	\N
81cdf9b6-3e98-4e19-93da-991dc7972699	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
363d0505-82fa-4353-ae92-f8333a36929b	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
92c82fdb-65a2-4660-bc61-8153bb43b877	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
1ace4664-7e46-4092-b5a2-be1742dfb681	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
ae85077f-0000-4e01-a71d-3dcdd8535f49	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
8f87499f-cf47-4d5f-9316-826503672b53	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
a89e7d21-7248-4966-b0e1-8dd31336f8db	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
e187c49f-3c84-45ad-93df-6ceefba26c9c	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
f4260903-e8bd-4dac-95c4-15edb722c299	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
803dff0b-62d2-430f-bd40-ba50e9fabc3c	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
302cca28-571e-427a-95d0-efca65becc5a	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
4675021d-61ff-4781-8efd-135e13c3ff7c	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
3ad819d1-97b0-49ab-b99a-29f93bed6429	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 20:59:26.778998+01	\N
14f2ce6a-cffa-4a92-8622-0c7a4341e3af	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
35b54fdd-7c4a-4e8c-95b0-89d346241567	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
f30d5286-8415-48d3-98e2-5c414f840feb	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
99b35acd-64bc-44fe-9e0d-b6ed8c168f2d	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
644e6d99-457e-4bbe-8d36-c0f70f85bad9	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
403e9f20-0893-40b2-b3d9-523276e2dd49	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
5c379150-ee74-4662-b89e-ae0cf8afe243	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
ac2aa5b6-9ce5-4024-ae81-4271551a48b8	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
3e9b678b-c2e6-4335-8108-a57aaf861148	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
cf9998c0-05da-442c-8d1a-02c80ff868c4	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
72b9e4b9-9ba0-4163-9448-2c5a4caa36d0	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
7b737b9a-b4f9-45f0-982a-f763e3398d86	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
83a6729f-2d4c-4a90-9824-5f19c5fbe037	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
c661a994-d91d-41fe-985e-0a6daf8fb575	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
e3b53e01-98e5-48d0-bff0-a7173b30e122	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
91d193ba-0a13-472b-939b-6cf6eca5e2d5	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
e5f58d60-66ca-4fc0-9bb2-277cdd8948f0	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
7608b34c-601c-4066-8d4c-4ae048720a80	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
d3b69104-2cb2-4be2-b6bb-daea6ed3df7d	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
48569f2f-0560-42cb-a38a-7d74b76608c5	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
26f391fd-21e4-4ba4-865f-8c44281c81ae	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
c8187430-cacf-42fa-9e00-3ef5ec9db828	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
6239559f-1708-413b-b0d4-5897376f9bcb	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
dc8d6aaa-bd1c-4fcd-9400-26897e562f8d	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
ad9a7149-4bce-4f59-87f9-dacce9836dfa	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
fd945c4b-6314-485f-b086-21306bedc68a	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
26720c0f-67e7-4607-9ed8-6c6b967ccc3c	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
010cd076-3e9f-4906-871f-6ba41d41083e	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
82472031-d02e-4075-8257-4e6693c48aa6	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
4c432265-b480-4a06-8002-ceefa7b520c3	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
733677c4-b443-4e47-94b9-a9d7d1513575	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
8dfcd9ed-79be-4c9f-a1a3-a86e7b997a9d	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
17b7e238-d37a-4c17-a7c4-6a559379d87a	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
1913850d-6b03-4458-b81d-140cbd63f323	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
4045a586-a6e8-41d2-8b5b-2142214dfe3d	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
3d3f6c45-e048-4094-9831-cb94b2898cac	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
4edce400-ff02-4bb9-93d7-601984f60035	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
6620d233-b71f-4ef6-a03e-5b7698b99cdd	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
32ed3075-5ac9-4dcc-ac83-57c7505c3f3a	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
bd710d33-0ce8-4559-8cf9-9a14e9094b86	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
9d68ba61-da62-4ca9-8478-0965986e96e3	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
737a5826-6dc8-4e83-9e62-dad7669a4594	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
7f3c5159-269b-4bcf-9877-e1c17ac0cd2e	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
03a9fc94-f50f-49d2-8786-112be149be91	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
1fbefa7e-b9ba-4f78-8df1-7f4d29de8d0e	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
062cd9a2-55c6-4f19-a62a-831626cc5be2	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
b90da277-37e7-4319-a6dd-cc8b3275be86	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	f	2026-09-16 21:04:44.282895+01	\N
f4b141cc-db3d-4781-8afd-243965c7cb30	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	21	5	0.00	\N	\N	f	2026-09-16 20:59:10.104282+01	\N
\.


--
-- Data for Name: products_backup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products_backup (id, nom, categorie_id, unite, quantite_actuelle, seuil_alerte, prix_unitaire_ht, date_peremption, numero_lot, actif, date_creation, deleted_at) FROM stdin;
a425d726-9e67-45e7-9d14-2fcb640b1b0a	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
4ae99a05-335e-4b12-b37b-951b49c118b0	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
3036f488-db16-4552-8c44-09f7ec31236c	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
e2a57fbe-05ce-44c8-9137-2dd8edac904b	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
0c75afe0-87d5-48e2-8112-bfade99d7e8e	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
933f035b-088b-4140-8cef-673cf235ba05	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
5cabfd37-e5d1-4c84-9d9f-beeb268e5c8b	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
835ae97b-2c87-4721-bca5-8a26c23142c1	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.068583+01	\N
4ef9f75d-9fe6-483c-9b0c-0fe1b3bca97c	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
67749606-f955-40d7-be79-798fbe5f1c41	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
4397f96e-6777-4d86-85b7-af3cb57bf3a7	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
aab2b54d-5a34-429b-8592-62c1fa142ab3	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
782ec6bb-8394-4c30-b53a-99ef785af4cc	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
1d278c31-0bdb-49b9-970c-df06f8b53dc7	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
7765e014-92c2-4d97-978e-88c5cc046233	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
c02d5dca-d3ba-40a7-a3a4-2173f0764dc3	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
2db4b267-7aca-4585-850b-711d4f9f5bf0	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
09050701-0b1a-4228-833b-233550e77536	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
126bf975-4870-4ceb-a715-b4116070a3c8	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
785247a7-de42-4541-b2c7-32a140b843bf	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
538c8d1b-f4d5-475e-84d6-8f3aeafd9d83	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
5fe63d8a-a833-4240-9984-5260508abcd9	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
2564a078-30c8-4135-8213-bd5d3ed59035	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
238bd42a-0679-43af-aa3a-a214dce7839b	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
3df9309e-9c2f-4742-bd9b-e423e4d07fff	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
24119285-a597-47b5-8e6a-15653dc664ad	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
8b50bded-c3e5-4a26-988e-bfe8bc7f1adb	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
b8a015f6-209f-4ca4-9781-27d9bc085a11	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
71433fed-8763-4fea-b4b6-63956dc5b998	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
e61e735b-06da-4a13-82fb-d5fab72249a1	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
7a74b7f6-3a8e-4a35-b190-0cad7d318f2b	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
3e86dcb8-41e8-48de-9254-78d6739806d2	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
6f9484d2-09a4-4e88-a132-2a9b11955654	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.127892+01	\N
728419ed-d393-4815-bed7-1b0c29ad814e	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
df2d2b73-dd54-4e4f-a019-fef31e22d4f2	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
bf593cac-d7c4-467e-a08a-5bc4a82615c1	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
26b6f47b-4f32-45f8-88b6-f48ed45dca98	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
553f3ea6-e1c3-420a-af2b-32f40aa71f81	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
a87bd709-d00b-42ae-98eb-95c277f65562	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
645fad04-e571-47d7-ae21-2d27be0b6e43	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
3e9752f1-52bf-44ee-aabc-fbd612966c52	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
f0497daa-fd29-420a-9880-163ac2c76f65	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
61afe0e3-4eb3-47bb-82c3-f5b985c3575c	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
ecf9fde1-dd35-42dd-8ba4-e25e1f8e38d2	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
cae1f6fa-99d8-44e5-93c6-986126fb1478	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
afb86f04-ed3f-4fb8-b891-f38dbd64db08	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:09.134864+01	\N
e13a2487-15c7-49a1-99e1-b9634aa3481c	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
39786dc8-c499-4c5c-8f15-c54c0cacb85f	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
63d9e769-4b3d-4490-8c4b-d1719329ee47	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
41b73ee0-e29e-4d27-bb52-93026ce84017	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
798f540a-ffdf-4166-9db1-49499650773f	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
d6488c9f-9334-4a96-a649-0ad5cbd97ff4	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
123b7db8-33c9-4b03-b241-f9dad1dc943d	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
e3266447-c43c-4ea6-a4c2-b3a3b8f0c42b	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.312211+01	\N
64f99efe-a642-4495-973f-a3a19a196c68	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
dca7aca9-6e07-4c76-a88e-39f07f1837a5	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
908c4262-759c-4089-ae5d-f627fbbbff3e	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
7ce66b8c-e4c0-46d2-a50f-e1493a7e9993	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
ee9e921e-b73c-41a3-98e8-e9c19757dfd8	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
ecc18cfe-bc99-4c06-a65e-dca5fd275476	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
6dbb8230-2436-4979-ae62-b119cf2c4a26	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
cba6b49e-3517-444d-a548-45aedfad1efc	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
64734c5f-ea61-44fc-8e7f-1def67a5bdcb	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
e629318d-4383-432f-9432-97c2cd40a584	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
2b9c8e8f-5abd-425f-86fb-fcbf0cf2a097	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.31993+01	\N
5ed86b5b-1582-47a1-8c64-e4f31d42085f	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
fcb29bce-e6fb-4837-9926-31d1bb9adfee	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
54f54bac-5e52-4a54-8faf-da9c613d3e1a	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
b9e75e8e-8718-4a63-bfc8-47d89790dbeb	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
0a7d2888-a8e3-4943-9002-56d7afe97178	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
2bca0b92-18ca-4fb0-ab58-222ac7565ba7	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
343f2f9e-10b7-44fe-971c-b453a8c32314	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
ad50586b-c7a3-4f88-826f-a0c19a839e22	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
9035d960-3a59-4529-99d8-6ac0d4c7cf97	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
dcc06130-dd80-4ee2-a500-fde395e08c3a	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
c68f8834-ee5a-4d85-8a97-71430936477c	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
ec6de852-e89e-468a-9c6e-0c74fe330d93	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
c02f434b-04d9-412e-baaa-a2709a668903	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
401be011-48a8-4ed2-bb76-dc0752c9a2f4	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
b3a6746c-0422-4e9a-903c-34e5aff0a795	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.328076+01	\N
da8ba5d8-8921-4cc6-b4c7-6ea3411591d3	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
672357c3-b6c4-4ff7-8127-5d2cf823d8fe	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
bdf75992-c7fa-4495-bf00-8ef9a172e9af	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
46f12e51-f20b-4a4c-ba78-1708dea275fe	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
024624c3-08c1-4f44-83f0-a55b2f3c715b	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
6359fe72-cac0-4030-84fa-dd66139bcd78	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
4af25d08-7feb-4997-b13b-19349868e24b	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
df7889cc-bf30-459b-92e2-5e3c107854da	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
a4dff494-1f36-478d-9d03-1b9ab40d3c75	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
3c651c07-d42c-4716-bedf-275495018744	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
97809d5c-df50-4a63-8968-d575646369f6	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
380b19d2-2433-40ef-b355-4924e173e954	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
5ae67f59-4a0c-481e-9dcd-87dfeeb31691	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:14.335394+01	\N
3e3756e4-adc7-4d76-85be-e89ed430d4b0	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
5d6f8932-4a4d-47a3-90a6-2de42f0b080d	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
90bc8bd3-8fe3-453d-8d6b-90160f17f9d3	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
801207c4-ea23-402a-9c90-78053fd5ff93	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
bd9569aa-6135-4cfc-a464-d6f1aa5f779a	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
9c6d77bc-7bbe-4741-b7f9-05d1d2719fdb	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
809c8f59-c267-4200-bf7a-dd45868ab4d8	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
8a3df9b5-7312-4025-833a-03e1289751a1	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.301936+01	\N
8acf6533-a956-42aa-b6a9-e1f48eeeae53	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
633d1717-6c36-4385-b57a-a78e3547bd3f	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
b5ff5900-4137-4301-ae67-375f2953b1fa	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
d867a451-e939-49ac-891f-a0658abbf7cd	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
9064fa96-647a-4207-8c95-837aa8fff0f4	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
433d1670-8510-43ff-aab6-ffb30e21aac6	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
7615fe58-336a-453d-bead-9b7efe8b5ef8	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
d5b93c55-2608-460f-b524-28bf9e76f70d	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
3d4be45a-f09c-483e-bea6-4d8938b24791	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
406eb81d-d322-45c8-adff-97de0e1521b2	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
7f1a4ea3-2389-4658-bd00-ae74a26488b5	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.307447+01	\N
c199e90a-e6a2-43c2-8c6b-c384436e8ef7	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
9abc1c7b-9412-4dda-8ab8-6925da6420ff	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
f915867b-7ae1-4f65-8786-efc8a8cab50b	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
34bcb842-c82b-433b-994e-9a66613361dc	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
780b1497-a263-4079-abee-73dcb9741a90	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
30b426ee-33e8-4c02-9979-2c00a53cbb40	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
4d419d14-6118-4aae-bef7-5092c2d1d430	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
799d324c-b76c-4cb9-96b8-baa7fa3bfb85	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
4c4aff76-8cf2-4fd7-b862-670b2461a554	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
978d4d75-ff93-4a0c-b3fb-098003652d9c	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
1dc2f1c6-e0da-4f24-ae4e-a18ed87c6964	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
c1485b33-b7e7-49a5-8a97-70853ae630b1	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
cdcc3fec-a037-40b8-b1d7-90fd1010ad83	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
6c26000f-4d48-47b7-b0a1-5944b22014d8	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
d6e304c5-1bf9-43ba-af22-3a3c68e209cb	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.314196+01	\N
93634e96-f620-47ff-91db-2210fb9e7235	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
d2d96d93-fa42-4d42-bd4f-b85c01496d14	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
5225e8e9-885f-4bb5-abc4-8f79f26e9026	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
519b5ea4-5d5a-42c4-b358-db72d0903eb2	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
39cf3e49-3aa7-44fb-953e-8f6683c9cf06	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
cec36251-7ca4-40db-ab85-48214be86fda	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
2f28844f-712f-44a6-b7cf-f2d20731f0a2	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
8996d4e1-7c77-4ea6-be65-81222db5d23e	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
e0636659-1723-4202-ba07-fe0f49bff2cf	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
7c4e54be-db9e-4288-86fa-eb8a0ccf442d	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
c298bc51-6481-4323-b6b3-8384e8c081c6	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
bbf39098-6880-4958-b278-6a9275aa9ce2	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
573259dc-40de-4804-9cf7-3402e9798e0f	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:17.320208+01	\N
f2dff041-f4c5-4e44-b51d-06c0f5ffbf06	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
8cf41363-ae68-47ee-ac65-3c03f367ad41	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
03795fef-d1e2-4c7e-b08e-79cbca361e43	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
f1fb33a7-294e-4355-a150-e2dc21f563da	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
7ce0d40b-22bb-4e52-bbf4-e2a7f022b19c	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
1a24fafd-2a29-4002-9828-26e24fdaebb8	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
de1c52ae-ff9b-4660-a46c-2cbcd430a308	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
4f229a2b-b156-4034-b3b2-9f71958f27a2	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:33.780769+01	\N
b3b1d4ad-07fc-46b2-8bf9-79d84e3d5172	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
87eff567-eb49-45fa-8956-efda0a86f0ac	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
d820130e-a78a-4759-9326-11f879a36c7d	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
6016c5f5-e138-40f8-b3b4-2548be431e15	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
6c186e98-1e82-4842-b469-3f34248dabeb	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
f87011f2-1ac6-4275-8e97-6c5809b1e308	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
6c00bc62-46c6-4ff1-8dc6-0131d634fa52	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
aa3a34a7-72df-487c-b31f-b5c6e315eb04	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:51.055364+01	\N
d376f1a5-65ba-4833-ab66-dc928faeefc2	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
0ec57d8b-e4cb-4b9c-a4f9-e0b3a6d64a58	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
74a325a0-842e-401c-ab08-5861b17e38b9	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
8d2749a8-7f78-41e0-923b-7ef51ec3ab20	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
96f43d95-f893-408c-a7dc-225951cb8a5e	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
4b914c2e-4c7e-48da-8fa0-271cfdfeb8ea	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
bfff8d90-41ac-48d5-9ced-f2d6c4d4ad44	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
84de6569-0d91-44c1-8ab4-f1b17346c98c	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:58:58.967327+01	\N
947d669b-fb77-4dd3-97a4-00b3e336a4e3	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
6679514d-95a2-403b-967f-6d4159567660	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
6e9ef9f6-c94f-4cf4-971c-797072bd980d	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
280ae3bf-afa7-4e7f-babd-64669948b090	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
113cc078-8f58-4276-aba6-bff45456688a	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
8e502401-9ad9-4b0a-9dfc-983fc46e2fb4	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
a3570be1-bfa5-46e1-bd32-62176dde0ee2	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
fc2cca13-ccbb-482b-bcf4-6c80bc52aa7c	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
3a90dde6-2004-43cc-a64a-80d291bba6d5	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
91c1f0f0-825a-432c-932c-677bb8e2f134	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
e3ff4ef1-b254-4faa-9b5a-db7b29f3b6ed	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:05.790406+01	\N
26465690-68b3-4da2-bc5e-ea3d23d45f28	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
eefabb73-5a9e-4568-bd5a-c9714dfd6ab1	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
63ce88d0-8a1c-41bc-a931-8d745eb85812	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
2d0e4914-8cfc-49d8-ba05-b8dd9147bc36	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
bc002e6f-6845-4754-8f6d-c9cab68b0c7d	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
fdd5fc9f-e167-40ae-8bc0-9824c2ae5236	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
fc75509c-1672-4060-9c96-f771e57065df	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
31bd90ed-9f11-4ca2-b40d-74dc7bdf2f7b	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
37ac808e-1e52-4b58-b229-9b624fe74126	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
361ce975-138c-49c2-a341-58980b8cee5c	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
e6a4535a-a9d6-4666-a6bb-d1c458ca15ea	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
6ac4de1f-ff3d-4eee-b4ad-9b38f86e295e	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
eec107df-fb74-4654-a9ea-db45d403c9be	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
3a8e0e88-dae9-4172-89ce-463befb4402a	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
98cece58-81a4-4998-b6e8-475b573b7647	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
01493711-b72a-4efa-a15d-0c6bc9be07b8	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
0adf8d7f-cb85-453c-8c9a-87326313588f	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
d492ca30-adb4-4ee1-888d-6bc3d5f81be7	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
e4bbb40d-f386-4a68-a50b-15178bd9d802	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
24423a40-cefd-4470-9178-1f6b84c39ae9	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
4993f2ec-0113-4d98-a893-98fdb58a3a68	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
c18db793-be25-4edc-a344-cd4e058ec8d8	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
8a147a6e-abac-4145-8f2b-2cf1fadf5cb9	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
11016ed9-e24a-469f-9c31-b6a448f3070d	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
7ca191fb-529d-4a6d-92b6-e5a9b82fe52f	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:14.78468+01	\N
9536361a-b050-4182-a8a8-0d89c9b430fe	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
7e24c8bc-57b6-4b89-8fa4-09cc0722bc08	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
c41b6ff6-1241-4df9-a346-ffeaee9d3930	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
6ba252e4-3abd-4405-b82b-b1c269965b89	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
3702b2c1-13b8-4632-944c-1d9ab1a89a17	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
79f34965-1cea-4f4b-8adb-746fe335a99b	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
40738519-fd00-4744-8522-90cd04a0a513	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
a9ecafb6-4b6b-4f0a-b7ee-12ec00e2da38	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
cdc19b29-d2a5-47b2-989f-ad694aac9cfe	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
57af31da-949e-4029-8e59-ccfe8a90a2ed	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
2dd4fcef-ba5b-4929-bf81-2f8ffdcf9688	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
e81012ad-bc44-4d19-9a69-0169c3e7f9a5	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
dbf71b89-0688-4a36-b78f-20c4a412cd22	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
6b35edef-a317-4591-91d6-361051bddf40	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
70ab6a5c-ad38-4f6a-bf20-4598756af9f7	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:17.612168+01	\N
92dd5fd5-9c26-4350-abdb-deb8d3a3cf55	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
e5e305f4-e237-429d-ae39-7a2f4c44ae61	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
035f3f6a-4172-4873-8888-a607f57d3ff4	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
0d42514a-0270-4029-be01-9170c08db158	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
f58bb119-b1d1-4fb4-9492-5a2dc3158818	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
5090b6ad-3f08-448c-a880-e5467bdcfb8f	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
818578cd-c937-41e9-a860-0741c55c49ee	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
de31204c-f9f8-4b01-a458-872d2dd08074	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
984727a1-db5c-4517-8ef5-1c855dcb6d87	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
63e23c9d-f050-4fcc-9b4d-3650d204fb6a	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
53ac4471-c513-498f-a990-1b5e8dfc7146	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
9436dfa2-a5e6-41fc-9cf6-e56b3aa56f92	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
477729bb-32d5-4a41-99f2-49326c9e51db	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:22.305629+01	\N
81cdf9b6-3e98-4e19-93da-991dc7972699	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
363d0505-82fa-4353-ae92-f8333a36929b	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
92c82fdb-65a2-4660-bc61-8153bb43b877	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
1ace4664-7e46-4092-b5a2-be1742dfb681	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
ae85077f-0000-4e01-a71d-3dcdd8535f49	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
8f87499f-cf47-4d5f-9316-826503672b53	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
a89e7d21-7248-4966-b0e1-8dd31336f8db	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
e187c49f-3c84-45ad-93df-6ceefba26c9c	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
f4260903-e8bd-4dac-95c4-15edb722c299	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
803dff0b-62d2-430f-bd40-ba50e9fabc3c	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
302cca28-571e-427a-95d0-efca65becc5a	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
4675021d-61ff-4781-8efd-135e13c3ff7c	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
3ad819d1-97b0-49ab-b99a-29f93bed6429	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 20:59:26.778998+01	\N
14f2ce6a-cffa-4a92-8622-0c7a4341e3af	Ten 20	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
35b54fdd-7c4a-4e8c-95b0-89d346241567	Aiguilles EMG Jaunes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
f30d5286-8415-48d3-98e2-5c414f840feb	Aiguilles EMG Vertes	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
99b35acd-64bc-44fe-9e0d-b6ed8c168f2d	Electrode de surface EMG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
644e6d99-457e-4bbe-8d36-c0f70f85bad9	Electrode patch câblée	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
403e9f20-0893-40b2-b3d9-523276e2dd49	Aiguilles PE	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
5c379150-ee74-4662-b89e-ae0cf8afe243	Gel EEG ECG	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
ac2aa5b6-9ce5-4024-ae81-4271551a48b8	Gel abrasif	18155e6c-2cfb-459f-b5b7-788e0099adb3	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
3e9b678b-c2e6-4335-8108-a57aaf861148	Bavette	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
cf9998c0-05da-442c-8d1a-02c80ff868c4	Gants	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
72b9e4b9-9ba0-4163-9448-2c5a4caa36d0	Cotton	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
7b737b9a-b4f9-45f0-982a-f763e3398d86	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
83a6729f-2d4c-4a90-9824-5f19c5fbe037	Compresse	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
c661a994-d91d-41fe-985e-0a6daf8fb575	Cebesine	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
e3b53e01-98e5-48d0-bff0-a7173b30e122	Mydricol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
91d193ba-0a13-472b-939b-6cf6eca5e2d5	Physiol	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
e5f58d60-66ca-4fc0-9bb2-277cdd8948f0	Dorzen	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
7608b34c-601c-4066-8d4c-4ae048720a80	Seringues	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
d3b69104-2cb2-4be2-b6bb-daea6ed3df7d	Calots	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
48569f2f-0560-42cb-a38a-7d74b76608c5	Javel	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
26f391fd-21e4-4ba4-865f-8c44281c81ae	Grésil	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
c8187430-cacf-42fa-9e00-3ef5ec9db828	Airfrech	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
6239559f-1708-413b-b0d4-5897376f9bcb	Désinfectant de surface	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
dc8d6aaa-bd1c-4fcd-9400-26897e562f8d	Dinol	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
ad9a7149-4bce-4f59-87f9-dacce9836dfa	Choc	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
fd945c4b-6314-485f-b086-21306bedc68a	Papier Hygiénique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
26720c0f-67e7-4607-9ed8-6c6b967ccc3c	Papier Essuie-tout	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
010cd076-3e9f-4906-871f-6ba41d41083e	Papier drap d'examen	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
82472031-d02e-4075-8257-4e6693c48aa6	Savon liquide	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
4c432265-b480-4a06-8002-ceefa7b520c3	Lingettes	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
733677c4-b443-4e47-94b9-a9d7d1513575	Sac poubelle	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
8dfcd9ed-79be-4c9f-a1a3-a86e7b997a9d	Goblet carton	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
17b7e238-d37a-4c17-a7c4-6a559379d87a	Goblet plastique	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
1913850d-6b03-4458-b81d-140cbd63f323	Brosse pour cupule	39671532-aaf8-4e70-a9ab-8390e7ca763b	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
4045a586-a6e8-41d2-8b5b-2142214dfe3d	Toner 85 a	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
3d3f6c45-e048-4094-9831-cb94b2898cac	Encre noire	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
4edce400-ff02-4bb9-93d7-601984f60035	Encre couleur	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
6620d233-b71f-4ef6-a03e-5b7698b99cdd	Rame papier	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
32ed3075-5ac9-4dcc-ac83-57c7505c3f3a	CD	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
bd710d33-0ce8-4559-8cf9-9a14e9094b86	Enveloppe	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
9d68ba61-da62-4ca9-8478-0965986e96e3	Fiche patient	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
737a5826-6dc8-4e83-9e62-dad7669a4594	Enveloppe pochette A3	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
7f3c5159-269b-4bcf-9877-e1c17ac0cd2e	Carte visite	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
03a9fc94-f50f-49d2-8786-112be149be91	Charge Agraffeuse	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
1fbefa7e-b9ba-4f78-8df1-7f4d29de8d0e	Scotch	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
062cd9a2-55c6-4f19-a62a-831626cc5be2	Boîtes archives	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
b90da277-37e7-4319-a6dd-cc8b3275be86	Note	2e893096-d8da-447d-ae9c-ab380bb87c33	pièce	10	5	0.00	\N	\N	t	2026-09-16 21:04:44.282895+01	\N
f4b141cc-db3d-4781-8afd-243965c7cb30	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	21	5	0.00	\N	\N	t	2026-09-16 20:59:10.104282+01	\N
4d1f7484-5632-41fb-ad22-7d9c134c60e5	Alcool	7037a957-46df-4daa-9fc7-cf80eb99e278	pièce	8	5	0.00	\N	\N	t	2026-09-16 20:58:09.117931+01	\N
5284ee53-a0f6-4731-b543-2900073e912e	hamdani	eb18ac27-d366-4445-ae8d-f2bb9d1a78fb	boite 	3	2	15.00	\N	\N	f	2026-09-27 22:26:42.484686+01	\N
211b0bfe-f4fc-4e29-94e6-7f1e26f6529d	Rihab 	2fcf9895-8635-48b1-9702-3c8a8880460d	paquet 	0	1	0.00	\N	\N	f	2026-10-02 17:54:46.936345+01	\N
29852bf1-a0df-4e19-bee4-9116213e793c	hiba 	2fcf9895-8635-48b1-9702-3c8a8880460d	pièce	5	5	0.00	\N	\N	f	2026-10-02 17:55:56.630005+01	\N
5b53bdca-9f3c-4587-a5de-60584b68477f	hamdnai 	eb18ac27-d366-4445-ae8d-f2bb9d1a78fb	pièce	10	5	15.00	2027-05-03	\N	f	2026-09-27 23:40:09.718618+01	2026-10-04 15:25:10.076097+01
2de79e26-745d-4edf-8e34-5f3445125d4a	__probe__	928d0a8b-82f8-4acd-9fd2-6ff59fc2d5a2	u	0	0	0.00	\N	\N	f	2026-10-04 13:45:37.003164+01	2026-10-04 23:19:49.676658+01
6f84beb4-d003-4424-8333-b077fb38b52c	Rihab	d754caae-3f2c-44a5-a14d-fb93a553c1b2	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:07:47.506933+01	2026-10-05 00:07:55.206246+01
ae399c49-536d-434e-b7d3-a5d7a571ffc7	r	23b5d129-8549-4209-bc9a-8387d74e7998	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:08:09.799408+01	2026-10-05 00:49:11.606637+01
21da7fcb-70a3-4446-81ed-a326a3ab0948	prod	94c7c02a-8a11-4fd8-8b98-0d89db1b965b	pièce	0	5	0.00	\N	\N	f	2026-10-05 00:33:11.078814+01	2026-10-05 00:49:14.697696+01
c53f6722-f80a-461c-ba0d-80080d14923f	rihab 	f7b858af-10ca-4b2f-856b-e91450274fac	pièce	0	5	0.00	\N	\N	f	2026-10-05 01:25:36.800886+01	2026-10-05 01:25:44.689704+01
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, nom, telephone, email, actif, date_creation) FROM stdin;
69c194ff-0af3-43af-9185-101dc335ea06	foulen	95058844	\N	t	2026-09-27 23:47:39.463796+01
29e777f9-8e46-4971-8fe5-02649778bc20	Transport	+216 95058844	\N	t	2026-10-05 23:42:15.289413+01
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, nom, prenom, email, mot_de_passe, telephone, role, actif, date_creation, reset_token, reset_token_expiration) FROM stdin;
f8e3b019-4da2-4fe6-8524-6f6c8f5afe3a	Secre	Secretaire	rihabisima05@gmail.com	$2a$10$BqOqtnFRQ1SuzDVZTEdnSuLh7/Je9JQw2MLYOSvPSBoNrxDWt0nWy	\N	SECRETAIRE	t	2026-10-25 12:31:40.208857+01	9d0c0e57-2bbd-4dbc-b0b1-6e7e836e9d4d	2026-10-25 13:44:13.067447+01
3e4d8150-2271-4e98-90f6-e4641b2756fd	Sec	Secrétaire 	rihab.hamdani@ieee.org	$2a$10$cRv.nS0sD8n03w8IoueJbe/Imk1KIh8yTytkAw1vt.ENFxtO3ecJS	\N	SECRETAIRE	t	2026-10-25 13:31:25.272976+01	\N	\N
8f935607-e16a-4ed1-b8b0-84bedb5ac34f	Hamdani	Rihab	hamdanirihab5@gmail.com	$2a$10$YhOnz5BmL9mY46F8UppJdeMPL.hMul35.64i.pfanH5zDrjJfgkr2	\N	MEDECIN	t	2026-10-25 11:04:49.532131+01	\N	\N
\.


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_nom_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_nom_key UNIQUE (nom);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_fcm_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_fcm_token_key UNIQUE (fcm_token);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: movements movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_pkey PRIMARY KEY (id);


--
-- Name: notification_logs notification_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_alerts_produit_ouverte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_alerts_produit_ouverte ON public.alerts USING btree (produit_id) WHERE ((statut)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMMANDEE'::character varying])::text[]));


--
-- Name: idx_alerts_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_alerts_statut ON public.alerts USING btree (statut);


--
-- Name: idx_device_tokens_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_device_tokens_user ON public.device_tokens USING btree (utilisateur_id);


--
-- Name: idx_movements_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_date ON public.movements USING btree (date_mouvement);


--
-- Name: idx_movements_produit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_produit ON public.movements USING btree (produit_id);


--
-- Name: idx_movements_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_user ON public.movements USING btree (utilisateur_id);


--
-- Name: idx_notif_logs_alerte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notif_logs_alerte ON public.notification_logs USING btree (alerte_id);


--
-- Name: idx_patients_date_rdv; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_date_rdv ON public.patients USING btree (date_rdv);


--
-- Name: idx_products_actif; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_actif ON public.products USING btree (actif);


--
-- Name: idx_products_categorie; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_categorie ON public.products USING btree (categorie_id);


--
-- Name: alerts alerts_commande_par_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_commande_par_fkey FOREIGN KEY (commande_par) REFERENCES public.users(id);


--
-- Name: alerts alerts_fournisseur_prevu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_fournisseur_prevu_id_fkey FOREIGN KEY (fournisseur_prevu_id) REFERENCES public.suppliers(id);


--
-- Name: alerts alerts_produit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_produit_id_fkey FOREIGN KEY (produit_id) REFERENCES public.products(id);


--
-- Name: device_tokens device_tokens_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: movements movements_fournisseur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_fournisseur_id_fkey FOREIGN KEY (fournisseur_id) REFERENCES public.suppliers(id);


--
-- Name: movements movements_produit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_produit_id_fkey FOREIGN KEY (produit_id) REFERENCES public.products(id);


--
-- Name: movements movements_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.users(id);


--
-- Name: notification_logs notification_logs_alerte_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_alerte_id_fkey FOREIGN KEY (alerte_id) REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: products products_categorie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_categorie_id_fkey FOREIGN KEY (categorie_id) REFERENCES public.categories(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict lTLYBtLd6cusYT4oYqGMTSTlwJyEK5KsHRFp6NRPeGFqhFKU3KuBnfvcgltYzue

