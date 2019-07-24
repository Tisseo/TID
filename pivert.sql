SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE SCHEMA pivert;
ALTER SCHEMA pivert OWNER TO :owner;

CREATE TYPE pivert.type_criticite AS ENUM (
    'faible',
    'moyenne',
    'forte'
);
ALTER TYPE pivert.type_criticite OWNER TO :owner;

CREATE TYPE pivert.type_etat AS ENUM (
    'OK',
    'KO',
    'PR'
);
ALTER TYPE pivert.type_etat OWNER TO :owner;

CREATE TYPE pivert.type_meca AS ENUM (
    'ASC',
    'EM'
);
ALTER TYPE pivert.type_meca OWNER TO :owner;


CREATE TABLE pivert.role (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    level integer NOT NULL
);
ALTER TABLE pivert.role OWNER TO :owner;


CREATE SEQUENCE pivert.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.role_id_seq OWNER TO :owner;
ALTER SEQUENCE pivert.role_id_seq OWNED BY pivert.role.id;


CREATE TABLE pivert."user" (
    id integer NOT NULL,
    login character varying(40) NOT NULL,
    password character varying(100) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    creation timestamp without time zone NOT NULL,
    role_id integer NOT NULL
);
ALTER TABLE pivert."user" OWNER TO :owner;

CREATE SEQUENCE pivert.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.user_id_seq OWNER TO :owner;
ALTER SEQUENCE pivert.user_id_seq OWNED BY pivert."user".id;


CREATE TABLE pivert.chemin (
    id_chemin integer NOT NULL,
    id_quai integer NOT NULL,
    id_entree integer NOT NULL
);
ALTER TABLE pivert.chemin OWNER TO :owner;


CREATE SEQUENCE pivert.chemin_id_chemin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.chemin_id_chemin_seq OWNER TO :owner;
ALTER SEQUENCE pivert.chemin_id_chemin_seq OWNED BY pivert.chemin.id_chemin;


CREATE TABLE pivert.entree (
    id_entree integer NOT NULL,
    id_station bigint NOT NULL,
    stop_area_id integer,
    adresse text,
    x double precision,
    y double precision,
    nb_asc integer NOT NULL,
    nb_esc integer NOT NULL,
    nb_esc_meca integer NOT NULL,
    nb_plain_pied integer NOT NULL
);
ALTER TABLE pivert.entree OWNER TO :owner;


CREATE SEQUENCE pivert.entree_id_entree_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.entree_id_entree_seq OWNER TO :owner;
ALTER SEQUENCE pivert.entree_id_entree_seq OWNED BY pivert.entree.id_entree;


CREATE TABLE pivert.mecanisme (
    id_mecanisme integer NOT NULL,
    id_station bigint NOT NULL,
    stop_area_id integer,
    ligne_a boolean NOT NULL,
    ligne_b boolean NOT NULL,
    type pivert.type_meca NOT NULL,
    etat pivert.type_etat NOT NULL,
    ref_technique character varying(50),
    ref_interne character varying(50),
    publication_info boolean NOT NULL,
    situation text,
    direction text,
    criticite pivert.type_criticite,
    cheminement_alternatif_haut text,
    cheminement_alternatif_bas text
);
ALTER TABLE pivert.mecanisme OWNER TO :owner;


CREATE SEQUENCE pivert.mecanisme_id_mecanisme_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.mecanisme_id_mecanisme_seq OWNER TO :owner;
ALTER SEQUENCE pivert.mecanisme_id_mecanisme_seq OWNED BY pivert.mecanisme.id_mecanisme;


CREATE TABLE pivert.panne (
    id_panne integer NOT NULL,
    id_mecanisme integer NOT NULL,
    debut_indispo date NOT NULL,
    fin_indispo date NOT NULL,
    fin_prevue date,
    ref_iv character varying(6) NOT NULL,
    version character varying(2) NOT NULL,
    motif character varying(255)
);
ALTER TABLE pivert.panne OWNER TO :owner;


CREATE SEQUENCE pivert.panne_id_panne_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.panne_id_panne_seq OWNER TO :owner;
ALTER SEQUENCE pivert.panne_id_panne_seq OWNED BY pivert.panne.id_panne;


CREATE TABLE pivert.quai (
    id_quai integer NOT NULL,
    id_station bigint NOT NULL,
    stop_area_id integer,
    libelle character varying(255),
    ligne character varying(1)
);
ALTER TABLE pivert.quai OWNER TO :owner;


CREATE SEQUENCE pivert.quai_id_quai_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.quai_id_quai_seq OWNER TO :owner;
ALTER SEQUENCE pivert.quai_id_quai_seq OWNED BY pivert.quai.id_quai;


CREATE TABLE pivert.quai_physique (
    id_quai integer NOT NULL,
    id_physique bigint NOT NULL,
    stop_id integer,
    montee boolean NOT NULL,
    descente boolean NOT NULL
);
ALTER TABLE pivert.quai_physique OWNER TO :owner;


CREATE SEQUENCE pivert.quai_physique_id_quai_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE pivert.quai_physique_id_quai_seq OWNER TO :owner;
ALTER SEQUENCE pivert.quai_physique_id_quai_seq OWNED BY pivert.quai_physique.id_quai;


CREATE TABLE pivert.liaison (
    id_chemin integer NOT NULL,
    id_mecanisme integer NOT NULL,
    ordre smallint NOT NULL
);
ALTER TABLE pivert.liaison OWNER TO :owner;


ALTER TABLE ONLY pivert.chemin ALTER COLUMN id_chemin SET DEFAULT nextval('pivert.chemin_id_chemin_seq'::regclass);
ALTER TABLE ONLY pivert.entree ALTER COLUMN id_entree SET DEFAULT nextval('pivert.entree_id_entree_seq'::regclass);
ALTER TABLE ONLY pivert.mecanisme ALTER COLUMN id_mecanisme SET DEFAULT nextval('pivert.mecanisme_id_mecanisme_seq'::regclass);
ALTER TABLE ONLY pivert.panne ALTER COLUMN id_panne SET DEFAULT nextval('pivert.panne_id_panne_seq'::regclass);
ALTER TABLE ONLY pivert.quai ALTER COLUMN id_quai SET DEFAULT nextval('pivert.quai_id_quai_seq'::regclass);
ALTER TABLE ONLY pivert.quai_physique ALTER COLUMN id_quai SET DEFAULT nextval('pivert.quai_physique_id_quai_seq'::regclass);

ALTER TABLE ONLY pivert.role ALTER COLUMN id SET DEFAULT nextval('pivert.role_id_seq'::regclass);
ALTER TABLE ONLY pivert."user" ALTER COLUMN id SET DEFAULT nextval('pivert.user_id_seq'::regclass);


ALTER TABLE ONLY pivert.chemin
    ADD CONSTRAINT chemin_pkey PRIMARY KEY (id_chemin);
ALTER TABLE ONLY pivert.entree
    ADD CONSTRAINT entree_pkey PRIMARY KEY (id_entree);
ALTER TABLE ONLY pivert.mecanisme
    ADD CONSTRAINT mecanisme_pkey PRIMARY KEY (id_mecanisme);
ALTER TABLE ONLY pivert.panne
    ADD CONSTRAINT panne_pkey PRIMARY KEY (id_panne);
ALTER TABLE ONLY pivert.quai_physique
    ADD CONSTRAINT quai_physique_pkey PRIMARY KEY (id_quai, id_physique);
ALTER TABLE ONLY pivert.quai
    ADD CONSTRAINT quai_pkey PRIMARY KEY (id_quai);
ALTER TABLE ONLY pivert.liaison
    ADD CONSTRAINT liaison_pkey PRIMARY KEY (id_chemin, id_mecanisme);
ALTER TABLE ONLY pivert.chemin
    ADD CONSTRAINT chemin_id_entree_fkey FOREIGN KEY (id_entree) REFERENCES pivert.entree(id_entree);
ALTER TABLE ONLY pivert.chemin
    ADD CONSTRAINT chemin_id_quai_fkey FOREIGN KEY (id_quai) REFERENCES pivert.quai(id_quai);
ALTER TABLE ONLY pivert.entree
    ADD CONSTRAINT stop_area_id_fkey FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) DEFERRABLE;
ALTER TABLE ONLY pivert.mecanisme
    ADD CONSTRAINT stop_area_id_fkey FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) DEFERRABLE;
ALTER TABLE ONLY pivert.quai
    ADD CONSTRAINT stop_area_id_fkey FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) DEFERRABLE;
ALTER TABLE ONLY pivert.quai_physique
    ADD CONSTRAINT stop_id_fkey FOREIGN KEY (stop_id) REFERENCES stop(id) DEFERRABLE;
ALTER TABLE ONLY pivert.panne
    ADD CONSTRAINT panne_id_mecanisme_fkey FOREIGN KEY (id_mecanisme) REFERENCES pivert.mecanisme(id_mecanisme);
ALTER TABLE ONLY pivert.liaison
    ADD CONSTRAINT liaison_id_chemin_fkey FOREIGN KEY (id_chemin) REFERENCES pivert.chemin(id_chemin);
ALTER TABLE ONLY pivert.liaison
    ADD CONSTRAINT liaison_id_mecanisme_fkey FOREIGN KEY (id_mecanisme) REFERENCES pivert.mecanisme(id_mecanisme);

ALTER TABLE ONLY pivert.role
    ADD CONSTRAINT role_name_key UNIQUE (name);
ALTER TABLE ONLY pivert.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
ALTER TABLE ONLY pivert."user"
    ADD CONSTRAINT user_login_key UNIQUE (login);
ALTER TABLE ONLY pivert."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


REVOKE ALL ON SCHEMA pivert FROM PUBLIC;
REVOKE ALL ON SCHEMA pivert FROM postgres;
GRANT ALL ON SCHEMA pivert TO postgres;
GRANT USAGE ON SCHEMA pivert TO :reader;
GRANT USAGE ON SCHEMA pivert TO :owner;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA pivert FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA pivert FROM postgres;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA pivert TO postgres;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA pivert TO :owner;

REVOKE ALL ON ALL TABLES IN SCHEMA pivert FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA pivert FROM postgres;
REVOKE ALL ON ALL TABLES IN SCHEMA pivert FROM :reader;
GRANT ALL ON ALL TABLES IN SCHEMA pivert TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA pivert TO :owner;
GRANT SELECT ON ALL TABLES IN SCHEMA pivert TO :reader;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA pivert FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA pivert FROM postgres;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA pivert FROM :reader;
GRANT ALL ON ALL SEQUENCES IN SCHEMA pivert TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA pivert TO :owner;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA pivert TO :reader;


ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON TABLES  TO :owner;

ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON SEQUENCES  TO :owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT SELECT ON SEQUENCES  TO :reader;

ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pivert GRANT ALL ON FUNCTIONS  TO :owner;
