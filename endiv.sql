--
-- Creation de la structure de tables ENDIV
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 274 (class 3079 OID 198832)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 274
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';

--
-- EXTENSION file_fdw; SERVER: file_fdw_server
--

CREATE EXTENSION IF NOT EXISTS file_fdw;
COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper which can be used to access data files in the (server)file system';
CREATE SERVER file_fdw_server FOREIGN DATA WRAPPER file_fdw;


SET search_path = public, pg_catalog;

--
-- TOC entry 1578 (class 1247 OID 199949)
-- Name: address; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE address AS (
	address character varying,
	the_geom character varying,
	is_entrance boolean
);


ALTER TYPE public.address OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 175 (class 1259 OID 199963)
-- Name: agency; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE agency (
    id integer NOT NULL,
    name character varying(30),
    url character varying(100),
    timezone character varying(30),
    lang character varying(3),
    phone character varying(20)
);


ALTER TABLE public.agency OWNER TO endiv_owner;

--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE agency; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE agency IS 'Reseau de transport en commun. Contient egalement le fuseau horaire et la langue.';


--
-- TOC entry 176 (class 1259 OID 199966)
-- Name: agency_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE agency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agency_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 176
-- Name: agency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE agency_id_seq OWNED BY agency.id;


--
-- TOC entry 177 (class 1259 OID 199968)
-- Name: alias; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE alias (
    id integer NOT NULL,
    stop_area_id integer,
    name character varying(255)
);


ALTER TABLE public.alias OWNER TO endiv_owner;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE alias; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE alias IS 'Alias des zones d''arrets.';


--
-- TOC entry 178 (class 1259 OID 199971)
-- Name: alias_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE alias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alias_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 178
-- Name: alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE alias_id_seq OWNED BY alias.id;


--
-- TOC entry 179 (class 1259 OID 199973)
-- Name: calendar; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE calendar (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    calendar_type integer NOT NULL
);


ALTER TABLE public.calendar OWNER TO endiv_owner;

--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE calendar; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE calendar IS 'Le calendrier d''application des services en production. Il est lui-meme compose de calendar_element.';


--
-- TOC entry 180 (class 1259 OID 199976)
-- Name: calendar_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE calendar_datasource (
    id integer NOT NULL,
    calendar_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.calendar_datasource OWNER TO endiv_owner;

--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calendar_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE calendar_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 181 (class 1259 OID 199979)
-- Name: calendar_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE calendar_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 181
-- Name: calendar_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_datasource_id_seq OWNED BY calendar_datasource.id;


--
-- TOC entry 182 (class 1259 OID 199981)
-- Name: calendar_element; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE calendar_element (
    id integer NOT NULL,
    calendar_id integer NOT NULL,
    start_date date,
    end_date date,
    positive character varying(1) NOT NULL,
    "interval" integer,
    included_calendar_id integer
);


ALTER TABLE public.calendar_element OWNER TO endiv_owner;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE calendar_element; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE calendar_element IS 'Element composant le calendrier. Il a comme champs les bornes, l''agencement avec d''autres calendar-element, un intervalle de repetition en cas de calendrier recurrent (lundi), et peut inclure un calendrier.';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN calendar_element.id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN calendar_element.id IS '
';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN calendar_element.positive; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN calendar_element.positive IS 'agencement des calendar_element d''un meme calendrier : ajout, soustraction, intersection avec les precedents';


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN calendar_element."interval"; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN calendar_element."interval" IS 'intervalle de repetition en cas de calendrier recurrent (lundi)';


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN calendar_element.included_calendar_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN calendar_element.included_calendar_id IS 'id du calendrier inclus';


--
-- TOC entry 183 (class 1259 OID 199984)
-- Name: calendar_element_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE calendar_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_element_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 183
-- Name: calendar_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_element_id_seq OWNED BY calendar_element.id;


--
-- TOC entry 184 (class 1259 OID 199986)
-- Name: calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 184
-- Name: calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_id_seq OWNED BY calendar.id;


--
-- TOC entry 185 (class 1259 OID 199988)
-- Name: calendar_link; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE calendar_link (
    id integer NOT NULL,
    trip_id integer NOT NULL,
    day_calendar_id integer NOT NULL,
    period_calendar_id integer NOT NULL
);


ALTER TABLE public.calendar_link OWNER TO endiv_owner;

--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE calendar_link; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE calendar_link IS 'Lien entre les calendriers et les services (trip) de production auxquels il s''applique.';


--
-- TOC entry 186 (class 1259 OID 199991)
-- Name: calendar_link_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE calendar_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_link_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 186
-- Name: calendar_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_link_id_seq OWNED BY calendar_link.id;


--
-- TOC entry 187 (class 1259 OID 199993)
-- Name: change_cause; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE change_cause (
    id integer NOT NULL,
    description character varying(255)
);


ALTER TABLE public.change_cause OWNER TO endiv_owner;

--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE change_cause; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE change_cause IS 'Motif de creation d''une nouvelle line_version.';


--
-- TOC entry 188 (class 1259 OID 199996)
-- Name: change_cause_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE change_cause_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.change_cause_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 188
-- Name: change_cause_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE change_cause_id_seq OWNED BY change_cause.id;


--
-- TOC entry 189 (class 1259 OID 199998)
-- Name: change_cause_link; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE change_cause_link (
    id integer NOT NULL,
    change_cause_id integer,
    line_version_id integer
);


ALTER TABLE public.change_cause_link OWNER TO endiv_owner;

--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE change_cause_link; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE change_cause_link IS 'Lien entre les motifs de nouvelle line_version et la line_version.';


--
-- TOC entry 190 (class 1259 OID 200001)
-- Name: change_cause_link_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE change_cause_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.change_cause_link_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 190
-- Name: change_cause_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE change_cause_link_id_seq OWNED BY change_cause_link.id;


--
-- TOC entry 191 (class 1259 OID 200003)
-- Name: city; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE city (
    id integer NOT NULL,
    insee character varying(5) NOT NULL,
    name character varying(255) NOT NULL,
    main_stop_area_id integer,
    the_geom geometry(Polygon,3943)
 );


ALTER TABLE public.city OWNER TO endiv_owner;

--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE city; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE city IS 'Commune.';


--
-- TOC entry 192 (class 1259 OID 200006)
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.city_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 192
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE city_id_seq OWNED BY city.id;


--
-- TOC entry 193 (class 1259 OID 200008)
-- Name: comment; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE comment (
    id integer NOT NULL,
    label character varying(5),
    comment_text character varying(255)
);


ALTER TABLE public.comment OWNER TO endiv_owner;

--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE comment; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE comment IS 'Note sur un itineraire (route) ou un service (trip). Signale une particularite sur les fiches horaire.';


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN comment.label; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN comment.label IS 'Lettre servant a signer le commentaire.';


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN comment.comment_text; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN comment.comment_text IS 'Description textuelle du commentaire.';


--
-- TOC entry 194 (class 1259 OID 200011)
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 194
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE comment_id_seq OWNED BY comment.id;


--
-- TOC entry 195 (class 1259 OID 200013)
-- Name: datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE datasource (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    agency_id integer NOT NULL
);


ALTER TABLE public.datasource OWNER TO endiv_owner;

--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE datasource IS 'Referentiel fournisseur de donnees. Les lignes saisies manuellement ont pour referentiel le ''Service donnes''.';


--
-- TOC entry 196 (class 1259 OID 200016)
-- Name: datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 196
-- Name: datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE datasource_id_seq OWNED BY datasource.id;


--
-- TOC entry 197 (class 1259 OID 200018)
-- Name: exception_type; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE exception_type (
    id integer NOT NULL,
    label character varying(5),
    exception_text character varying(255),
    grid_calendar_pattern character varying(7),
    trip_calendar_pattern character varying(7)
);


ALTER TABLE public.exception_type OWNER TO endiv_owner;

--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE exception_type; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE exception_type IS 'Base de connaissance des type de commentaires.';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN exception_type.label; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN exception_type.label IS 'Lettre servant a signer le commentaire.';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN exception_type.exception_text; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN exception_type.exception_text IS 'Description textuelle du commentaire.';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN exception_type.grid_calendar_pattern; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN exception_type.grid_calendar_pattern IS 'Circulation LMMJVSD de la grille horaire cible.';


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN exception_type.trip_calendar_pattern; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN exception_type.trip_calendar_pattern IS 'Circulation LMMJVSD du service cible.';


--
-- TOC entry 198 (class 1259 OID 200021)
-- Name: exception_type_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE exception_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.exception_type_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 198
-- Name: exception_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE exception_type_id_seq OWNED BY exception_type.id;


--
-- TOC entry 199 (class 1259 OID 200023)
-- Name: export_destination; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE export_destination (
    id integer NOT NULL,
    nom character varying(255),
    url text
);


ALTER TABLE public.export_destination OWNER TO endiv_owner;

--
-- TOC entry 200 (class 1259 OID 200029)
-- Name: export_destination_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE export_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.export_destination_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 200
-- Name: export_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE export_destination_id_seq OWNED BY export_destination.id;


--
-- TOC entry 201 (class 1259 OID 200031)
-- Name: export_perso; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE export_perso (
    table_name character varying(30) NOT NULL
);


ALTER TABLE public.export_perso OWNER TO endiv_owner;

--
-- TOC entry 202 (class 1259 OID 200034)
-- Name: export_prod; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE export_prod (
    table_name character varying(30) NOT NULL
);


ALTER TABLE public.export_prod OWNER TO endiv_owner;

--
-- TOC entry 203 (class 1259 OID 200037)
-- Name: grid_calendar; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE grid_calendar (
    id integer NOT NULL,
    line_version_id integer,
    name character varying(255) NOT NULL,
    color character varying(7) NOT NULL,
    monday boolean NOT NULL,
    tuesday boolean NOT NULL,
    wednesday boolean NOT NULL,
    thursday boolean NOT NULL,
    friday boolean NOT NULL,
    saturday boolean NOT NULL,
    sunday boolean NOT NULL
);


ALTER TABLE public.grid_calendar OWNER TO endiv_owner;

--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE grid_calendar; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE grid_calendar IS 'Grille horaire d''une fiche horaire. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';


--
-- TOC entry 204 (class 1259 OID 200040)
-- Name: grid_calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE grid_calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grid_calendar_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 204
-- Name: grid_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_calendar_id_seq OWNED BY grid_calendar.id;


--
-- TOC entry 205 (class 1259 OID 200042)
-- Name: grid_link_calendar_mask_type; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE grid_link_calendar_mask_type (
    id integer NOT NULL,
    grid_calendar_id integer NOT NULL,
    grid_mask_type_id integer NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.grid_link_calendar_mask_type OWNER TO endiv_owner;

--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE grid_link_calendar_mask_type; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE grid_link_calendar_mask_type IS 'Lien entre les calendriers Hastus fiche horaire et les grilles horaires de la fiche. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';


--
-- TOC entry 206 (class 1259 OID 200045)
-- Name: grid_link_calendar_mask_type_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE grid_link_calendar_mask_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grid_link_calendar_mask_type_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 206
-- Name: grid_link_calendar_mask_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_link_calendar_mask_type_id_seq OWNED BY grid_link_calendar_mask_type.id;


--
-- TOC entry 207 (class 1259 OID 200047)
-- Name: grid_mask_type; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE grid_mask_type (
    id integer NOT NULL,
    calendar_type character varying(50),
    calendar_period character varying(100)
);


ALTER TABLE public.grid_mask_type OWNER TO endiv_owner;

--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE grid_mask_type; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE grid_mask_type IS 'Type des calendriers envoyes par Hastus pour les fiches horaires.Table remplie par l''import Hastus FICHOR pour les lignes exploitees par Tisseo.';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN grid_mask_type.calendar_type; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN grid_mask_type.calendar_type IS 'Type du calendrier. Semaine correspond à LaV si un type Samedi existe sur l''offre et à LaS sinon. Dimanche regroupe egalement les jours feries.';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN grid_mask_type.calendar_period; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN grid_mask_type.calendar_period IS 'Periode d''application du calendrier. BASE correspond a la periode hors vacances si une periode vacance existe sur cette offre et a la periode hiver sinon.';


--
-- TOC entry 208 (class 1259 OID 200050)
-- Name: grid_mask_type_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE grid_mask_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grid_mask_type_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 208
-- Name: grid_mask_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_mask_type_id_seq OWNED BY grid_mask_type.id;


--
-- TOC entry 209 (class 1259 OID 200052)
-- Name: line; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE line (
    id integer NOT NULL,
    number character varying(10) NOT NULL,
    physical_mode_id integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE public.line OWNER TO endiv_owner;

--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE line; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE line IS 'Ligne commerciale de TC.';


--
-- TOC entry 210 (class 1259 OID 200055)
-- Name: line_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE line_datasource (
    id integer NOT NULL,
    line_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.line_datasource OWNER TO endiv_owner;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE line_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE line_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 211 (class 1259 OID 200058)
-- Name: line_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE line_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 211
-- Name: line_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_datasource_id_seq OWNED BY line_datasource.id;


--
-- TOC entry 212 (class 1259 OID 200060)
-- Name: line_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 212
-- Name: line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_id_seq OWNED BY line.id;


--
-- TOC entry 213 (class 1259 OID 200062)
-- Name: line_version; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE line_version (
    id integer NOT NULL,
    line_id integer NOT NULL,
    version integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    planned_end_date date NOT NULL,
    child_line_id integer,
    name character varying(255) NOT NULL,
    forward_direction character varying(255) NOT NULL,
    backward_direction character varying(255) NOT NULL,
    bg_color character varying(20) DEFAULT 'blanc' NOT NULL ,
    bg_hexa_color character varying(7) DEFAULT '#FFFFFF' NOT NULL,
    fg_color character varying(20) DEFAULT 'noir' NOT NULL,
    fg_hexa_color character varying(7) DEFAULT '#000000' NOT NULL,
    carto_file text,
    accessibility boolean ,
    air_conditioned boolean,
    certified boolean DEFAULT false NOT NULL,
    comment text,
    depot character varying(50)
);


ALTER TABLE public.line_version OWNER TO endiv_owner;

--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE line_version; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE line_version IS 'Offre d''une ligne.';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN line_version.start_date; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN line_version.start_date IS 'Date de debut d''offre.';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN line_version.end_date; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN line_version.end_date IS 'Date effective de fin d''offre, non reneignee a la creation.';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN line_version.planned_end_date; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN line_version.planned_end_date IS 'Date de fin previsionnelle d''offre.';


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN line_version.child_line_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN line_version.child_line_id IS 'Ligne rattachee (ligne de soiree)';


--
-- TOC entry 214 (class 1259 OID 200069)
-- Name: line_version_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE line_version_datasource (
    id integer NOT NULL,
    line_version_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.line_version_datasource OWNER TO endiv_owner;

--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE line_version_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE line_version_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 215 (class 1259 OID 200072)
-- Name: line_version_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE line_version_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_version_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 215
-- Name: line_version_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_datasource_id_seq OWNED BY line_version_datasource.id;


--
-- TOC entry 216 (class 1259 OID 200074)
-- Name: line_version_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE line_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_version_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 216
-- Name: line_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_id_seq OWNED BY line_version.id;


--
-- TOC entry 217 (class 1259 OID 200076)
-- Name: line_version_not_exported; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE line_version_not_exported (
    id integer NOT NULL,
    line_version_id integer,
    export_destination_id integer
);


ALTER TABLE public.line_version_not_exported OWNER TO endiv_owner;

--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE line_version_not_exported; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE line_version_not_exported IS 'Line_version qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';


--
-- TOC entry 218 (class 1259 OID 200079)
-- Name: line_version_not_exported_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE line_version_not_exported_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.line_version_not_exported_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 218
-- Name: line_version_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_not_exported_id_seq OWNED BY line_version_not_exported.id;


--
-- TOC entry 219 (class 1259 OID 200081)
-- Name: log; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE log (
    id integer NOT NULL,
    datetime timestamp without time zone NOT NULL,
    "table" character varying(30) NOT NULL,
    action character varying(20) NOT NULL,
    previous_data text,
    inserted_data text,
    "user" character varying(30) NOT NULL
);


ALTER TABLE public.log OWNER TO endiv_owner;

--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE log; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE log IS 'Trace de toutes les operations sur la base.';


--
-- TOC entry 220 (class 1259 OID 200087)
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 220
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE log_id_seq OWNED BY log.id;


--
-- TOC entry 221 (class 1259 OID 200089)
-- Name: non_concurrency; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE non_concurrency (
    priority_line_id integer NOT NULL,
    non_priority_line_id integer NOT NULL,
    "time" integer NOT NULL
);


ALTER TABLE public.non_concurrency OWNER TO endiv_owner;

--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE non_concurrency; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE non_concurrency IS 'Table des non concurrences, une ligne est prioritaire sur une autre pour un delta de temps.';


--
-- TOC entry 222 (class 1259 OID 200092)
-- Name: odt_area; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE odt_area (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    comment text
);


ALTER TABLE public.odt_area OWNER TO endiv_owner;

--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE odt_area; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE odt_area IS 'Zone d''arret TAD.';


--
-- TOC entry 223 (class 1259 OID 200098)
-- Name: odt_stop; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE odt_stop (
    odt_area_id integer NOT NULL,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    pickup boolean NOT NULL,
    drop_off boolean NOT NULL
);


ALTER TABLE public.odt_stop OWNER TO endiv_owner;

--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE odt_stop; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE odt_stop IS 'Lien entre un arret et une zone d''arret pour un intervalle de temps.';


--
-- TOC entry 224 (class 1259 OID 200101)
-- Name: physical_mode; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE physical_mode (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    type character varying(30) NOT NULL
);


ALTER TABLE public.physical_mode OWNER TO endiv_owner;

--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE physical_mode; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE physical_mode IS 'Mode de transport.';


--
-- TOC entry 225 (class 1259 OID 200104)
-- Name: physical_mode_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE physical_mode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.physical_mode_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 225
-- Name: physical_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE physical_mode_id_seq OWNED BY physical_mode.id;


--
-- TOC entry 226 (class 1259 OID 200106)
-- Name: poi; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE poi (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    city_id integer NOT NULL,
    poi_type_id integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE public.poi OWNER TO endiv_owner;

--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE poi; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE poi IS 'Point d''interet. ';


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN poi.city_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi.city_id IS 'Commune du POI.';


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN poi.poi_type_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi.poi_type_id IS 'Categorie de POI.';


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN poi.priority; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi.priority IS 'Importance du POI. 1 = prioritaire, 5 = peu important.';


--
-- TOC entry 227 (class 1259 OID 200109)
-- Name: poi_address; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE poi_address (
    id integer NOT NULL,
    poi_id integer NOT NULL,
    address text,
    is_entrance boolean NOT NULL,
    the_geom geometry(Point,3943) NOT NULL
);


ALTER TABLE public.poi_address OWNER TO endiv_owner;

--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE poi_address; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE poi_address IS 'Localisation du POI ou de son entree.';


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN poi_address.id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi_address.id IS '
';


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN poi_address.address; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi_address.address IS 'Adresse postale de la localisation du POI.';


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN poi_address.is_entrance; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi_address.is_entrance IS 'Indique sil la localisation est une entree du POI ou le barycentre du POI.';


--
-- TOC entry 228 (class 1259 OID 200115)
-- Name: poi_address_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE poi_address_datasource (
    id integer NOT NULL,
    poi_address_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.poi_address_datasource OWNER TO endiv_owner;

--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE poi_address_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE poi_address_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 229 (class 1259 OID 200118)
-- Name: poi_address_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_address_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_address_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 229
-- Name: poi_address_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_address_datasource_id_seq OWNED BY poi_address_datasource.id;


--
-- TOC entry 230 (class 1259 OID 200120)
-- Name: poi_address_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_address_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 230
-- Name: poi_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_address_id_seq OWNED BY poi_address.id;


--
-- TOC entry 231 (class 1259 OID 200122)
-- Name: poi_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE poi_datasource (
    id integer NOT NULL,
    poi_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.poi_datasource OWNER TO endiv_owner;

--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE poi_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE poi_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 232 (class 1259 OID 200125)
-- Name: poi_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 232
-- Name: poi_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_datasource_id_seq OWNED BY poi_datasource.id;


--
-- TOC entry 233 (class 1259 OID 200127)
-- Name: poi_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 233
-- Name: poi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_id_seq OWNED BY poi.id;


--
-- TOC entry 234 (class 1259 OID 200129)
-- Name: poi_type; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE poi_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.poi_type OWNER TO endiv_owner;

--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE poi_type; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE poi_type IS 'Categorie de POI.';


--
-- TOC entry 235 (class 1259 OID 200132)
-- Name: poi_type_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_type_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 235
-- Name: poi_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_type_id_seq OWNED BY poi_type.id;


--
-- TOC entry 236 (class 1259 OID 200134)
-- Name: printing; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE printing (
    id integer NOT NULL,
    quantity integer,
    date date,
    line_version_id integer,
    comment text
);


ALTER TABLE public.printing OWNER TO endiv_owner;

--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE printing; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE printing IS 'Quatite de fiche horaire d''une offre imprimees. Aide a la gestion des document IV.';


--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN printing.comment; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN printing.comment IS 'Raison du tirage : initial, reassort ou correction.';


--
-- TOC entry 237 (class 1259 OID 200140)
-- Name: printing_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE printing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.printing_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 237
-- Name: printing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE printing_id_seq OWNED BY printing.id;


--
-- TOC entry 238 (class 1259 OID 200142)
-- Name: route; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE route (
    id integer NOT NULL,
    line_version_id integer NOT NULL,
    way character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    direction character varying(255) NOT NULL,
    comment_id integer
);


ALTER TABLE public.route OWNER TO endiv_owner;

--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE route; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE route IS 'Itineraire d''une offre. ';


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN route.way; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route.way IS 'Aller ou retour.';


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN route.name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route.name IS 'Nom du parcours type (Hastus ou Tigre).';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN route.direction; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route.direction IS 'Titre de la direction, a terme, viendra de l''application girouette.';


--
-- TOC entry 239 (class 1259 OID 200145)
-- Name: route_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE route_datasource (
    id integer NOT NULL,
    route_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.route_datasource OWNER TO endiv_owner;

--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE route_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE route_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 240 (class 1259 OID 200148)
-- Name: route_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE route_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 240
-- Name: route_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_datasource_id_seq OWNED BY route_datasource.id;


--
-- TOC entry 241 (class 1259 OID 200150)
-- Name: route_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE route_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 241
-- Name: route_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_id_seq OWNED BY route.id;


--
-- TOC entry 242 (class 1259 OID 200152)
-- Name: route_not_exported; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE route_not_exported (
    id integer NOT NULL,
    route_id integer,
    export_destination_id integer
);


ALTER TABLE public.route_not_exported OWNER TO endiv_owner;

--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE route_not_exported; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE route_not_exported IS 'Routes qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';


--
-- TOC entry 243 (class 1259 OID 200155)
-- Name: route_not_exported_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE route_not_exported_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_not_exported_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 243
-- Name: route_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_not_exported_id_seq OWNED BY route_not_exported.id;


--
-- TOC entry 244 (class 1259 OID 200157)
-- Name: route_section; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE route_section (
    id integer NOT NULL,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    the_geom geometry(LineString,3943) NOT NULL
);


ALTER TABLE public.route_section OWNER TO endiv_owner;

--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE route_section; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE route_section IS 'Troncon inter-arrets provenant de Tigre. Les dates permettent de gerer des changement de parcours entre 2 arrets. Un troncon est unique pour une geometrie et ses arrets depart-arrivee.';


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN route_section.start_date; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_section.start_date IS 'Date de la creation de ce troncon. Un nouveau troncon est cree si arret debut ou arret fin ou geom est nouvelle.';


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN route_section.end_date; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_section.end_date IS 'Date de fin d''utilisation du troncon. Lorsqu''un nouveau troncon (meme debut, meme fin mais geom differente) est cree, le precedentest cloture.';


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN route_section.the_geom; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_section.the_geom IS 'Geometrie de Tigre.';


--
-- TOC entry 245 (class 1259 OID 200163)
-- Name: route_section_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE route_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_section_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 245
-- Name: route_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_section_id_seq OWNED BY route_section.id;


--
-- TOC entry 246 (class 1259 OID 200165)
-- Name: route_stop; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE route_stop (
    id integer NOT NULL,
    route_id integer NOT NULL,
    waypoint_id integer NOT NULL,
    rank integer NOT NULL,
    scheduled_stop boolean NOT NULL,
    pickup boolean NOT NULL,
    drop_off boolean NOT NULL,
    reservation_required boolean NOT NULL,
    route_section_id integer,
    internal_service boolean
);


ALTER TABLE public.route_stop OWNER TO endiv_owner;

--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE route_stop; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE route_stop IS 'Troncon d''un itineraire, qui passe par un waypoint selon un rang.';


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN route_stop.route_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_stop.route_id IS 'Itineraire du troncon.';


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN route_stop.waypoint_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_stop.waypoint_id IS 'Point de passage du debut du troncon. Peut renvoyer vers un arret ou une zone TAD.';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN route_stop.rank; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_stop.rank IS 'Ordre dans l''itineraire. Commence a 1.';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN route_stop.scheduled_stop; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_stop.scheduled_stop IS 'Indique s''il s''agit d''un waypoint qui comporte des horaires.';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN route_stop.internal_service; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN route_stop.internal_service IS 'Dans le cas d''une zone TAD, idique si la desserte interne de la zone est autorisee.';


--
-- TOC entry 247 (class 1259 OID 200168)
-- Name: route_stop_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE route_stop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_stop_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 247
-- Name: route_stop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_stop_id_seq OWNED BY route_stop.id;


--
-- TOC entry 248 (class 1259 OID 200170)
-- Name: stop; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop (
    id integer NOT NULL,
    stop_area_id integer NOT NULL,
    master_stop_id integer
);


ALTER TABLE public.stop OWNER TO endiv_owner;

--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE stop; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop IS 'Arret de bus ou de TAD, quai de tram ou de metro.';


--
-- TOC entry 249 (class 1259 OID 200173)
-- Name: stop_area; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop_area (
    id integer NOT NULL,
    short_name character varying(255) NOT NULL,
    long_name character varying(255),
    city_id integer NOT NULL,
    transfer_duration integer NOT NULL,
    the_geom geometry(Point,3943)
);


ALTER TABLE public.stop_area OWNER TO endiv_owner;

--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE stop_area; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop_area IS 'Zone d''arret comportant un ou plusieurs arrets.';


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN stop_area.short_name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_area.short_name IS 'Nom identique aux noms des arrets le composant.';


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN stop_area.long_name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_area.long_name IS 'Par defaut, le long_name est identique aux noms des arrets le composant, il peut etre modifie pour developper les abbreviations du nom court.';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN stop_area.transfer_duration; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_area.transfer_duration IS 'Temps en secondes de transfert entre deux arret de cette zone d''arrets.';


--
-- TOC entry 250 (class 1259 OID 200179)
-- Name: stop_area_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop_area_datasource (
    id integer NOT NULL,
    stop_area_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.stop_area_datasource OWNER TO endiv_owner;

--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE stop_area_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop_area_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 251 (class 1259 OID 200182)
-- Name: stop_area_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE stop_area_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stop_area_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 251
-- Name: stop_area_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_area_datasource_id_seq OWNED BY stop_area_datasource.id;


--
-- TOC entry 252 (class 1259 OID 200184)
-- Name: stop_area_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE stop_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stop_area_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 252
-- Name: stop_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_area_id_seq OWNED BY stop_area.id;


--
-- TOC entry 253 (class 1259 OID 200186)
-- Name: stop_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop_datasource (
    id integer NOT NULL,
    stop_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.stop_datasource OWNER TO endiv_owner;

--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE stop_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 254 (class 1259 OID 200189)
-- Name: stop_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE stop_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stop_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 254
-- Name: stop_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_datasource_id_seq OWNED BY stop_datasource.id;


--
-- TOC entry 255 (class 1259 OID 200191)
-- Name: stop_history; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop_history (
    id integer NOT NULL,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    short_name character varying(50) NOT NULL,
    long_name character varying(255),
    the_geom geometry(Point,3943) NOT NULL,
    accessibility boolean
);


ALTER TABLE public.stop_history OWNER TO endiv_owner;

--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE stop_history; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop_history IS 'Proprietes d''un arret. Un arret n''a qu''un historique dans le temps. Si une caracteristique cahnge, l''historique precedent est cloture et un nouveau est cree.';


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN stop_history.short_name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_history.short_name IS 'Nom de l''arret dans le referentiel Hastus. Pas de modification possible.';


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN stop_history.long_name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_history.long_name IS 'Champ inutile pour le moment. Laisser vide.';


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN stop_history.accessibility; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_history.accessibility IS 'Accessibilite de l''arret pour les UFR (fauteuil roulant) selon les releves du service accessibilite.';


--
-- TOC entry 256 (class 1259 OID 200197)
-- Name: stop_history_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE stop_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stop_history_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 256
-- Name: stop_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_history_id_seq OWNED BY stop_history.id;


--
-- TOC entry 257 (class 1259 OID 200199)
-- Name: stop_time; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE stop_time (
    id integer NOT NULL,
    route_stop_id integer NOT NULL,
    trip_id integer NOT NULL,
    arrival_time integer,
    departure_time integer
);


ALTER TABLE public.stop_time OWNER TO endiv_owner;

--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE stop_time; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE stop_time IS 'Horaire d''un troncon d''itineraire.';


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN stop_time.arrival_time; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_time.arrival_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN stop_time.departure_time; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN stop_time.departure_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';


--
-- TOC entry 258 (class 1259 OID 200202)
-- Name: stop_time_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE stop_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stop_time_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 258
-- Name: stop_time_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_time_id_seq OWNED BY stop_time.id;


--
-- TOC entry 259 (class 1259 OID 200204)
-- Name: transfer; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE transfer (
    id integer NOT NULL,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    duration integer NOT NULL,
    distance integer,
    the_geom geometry(Point,3943),
    accessibility boolean,
    description text
);


ALTER TABLE public.transfer OWNER TO endiv_owner;

--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE transfer; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE transfer IS 'Correspondance entre deux arrets.';


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN transfer.duration; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN transfer.duration IS 'Temps de transfert en secondes.';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN transfer.distance; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN transfer.distance IS 'Distance en metres de la correspondance.';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN transfer.the_geom; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN transfer.the_geom IS 'Trace de la correspondance. Inutilise pour le moment.';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN transfer.accessibility; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN transfer.accessibility IS 'Accessibilite de la correspondance. Inutilise pour le moment.';


--
-- TOC entry 260 (class 1259 OID 200210)
-- Name: transfer_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE transfer_datasource (
    id integer NOT NULL,
    transfer_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.transfer_datasource OWNER TO endiv_owner;

--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE transfer_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE transfer_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 261 (class 1259 OID 200213)
-- Name: transfer_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE transfer_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 261
-- Name: transfer_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_datasource_id_seq OWNED BY transfer_datasource.id;


--
-- TOC entry 262 (class 1259 OID 200215)
-- Name: transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE transfer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 262
-- Name: transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_id_seq OWNED BY transfer.id;


--
-- TOC entry 263 (class 1259 OID 200217)
-- Name: transfer_not_exported; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE transfer_not_exported (
    id integer NOT NULL,
    transfer_id integer,
    export_destination_id integer
);


ALTER TABLE public.transfer_not_exported OWNER TO endiv_owner;

--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE transfer_not_exported; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE transfer_not_exported IS 'Correspondances qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';


--
-- TOC entry 264 (class 1259 OID 200220)
-- Name: transfer_not_exported_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE transfer_not_exported_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_not_exported_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 264
-- Name: transfer_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_not_exported_id_seq OWNED BY transfer_not_exported.id;


--
-- TOC entry 265 (class 1259 OID 200222)
-- Name: trip; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE trip (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    route_id integer NOT NULL,
    trip_calendar_id integer,
    comment_id integer
);


ALTER TABLE public.trip OWNER TO endiv_owner;

--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE trip; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE trip IS 'Service d''un itineraire. Fait le lien entre les horaires et les itineraires.';


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN trip.name; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN trip.name IS 'Nom de l''objet. Si vient d''Hastus, identiques a la datasource.';


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN trip.trip_calendar_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN trip.trip_calendar_id IS 'Lien vers un calendrier de fiche horaire. Null si il s''agit d''un service de prod non present dans les fiches horaires.';


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN trip.comment_id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN trip.comment_id IS 'Lien vers les commentaires pour les fiches horaires.';


--
-- TOC entry 266 (class 1259 OID 200225)
-- Name: trip_calendar; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE trip_calendar (
    id integer NOT NULL,
    grid_mask_type_id integer NOT NULL,
    monday boolean NOT NULL,
    tuesday boolean NOT NULL,
    wednesday boolean NOT NULL,
    thursday boolean NOT NULL,
    friday boolean NOT NULL,
    saturday boolean NOT NULL,
    sunday boolean NOT NULL
);


ALTER TABLE public.trip_calendar OWNER TO endiv_owner;

--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE trip_calendar; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE trip_calendar IS 'Description des jours de circulation des services (trips) pour les fiches horaires. Table remplie par l''import Hastus FICHOR pour les lignes exploitees par Tisseo.';


--
-- TOC entry 267 (class 1259 OID 200228)
-- Name: trip_calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE trip_calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trip_calendar_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 267
-- Name: trip_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_calendar_id_seq OWNED BY trip_calendar.id;


--
-- TOC entry 268 (class 1259 OID 200230)
-- Name: trip_datasource; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE trip_datasource (
    id integer NOT NULL,
    trip_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.trip_datasource OWNER TO endiv_owner;

--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE trip_datasource; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON TABLE trip_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


--
-- TOC entry 269 (class 1259 OID 200233)
-- Name: trip_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE trip_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trip_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 269
-- Name: trip_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_datasource_id_seq OWNED BY trip_datasource.id;


--
-- TOC entry 270 (class 1259 OID 200235)
-- Name: trip_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trip_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 270
-- Name: trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_id_seq OWNED BY trip.id;


--
-- TOC entry 271 (class 1259 OID 200237)
-- Name: waypoint; Type: TABLE; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE TABLE waypoint (
    id integer NOT NULL
);


ALTER TABLE public.waypoint OWNER TO endiv_owner;

--
-- TOC entry 272 (class 1259 OID 200240)
-- Name: waypoint_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE waypoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.waypoint_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 272
-- Name: waypoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE waypoint_id_seq OWNED BY waypoint.id;


--
-- TOC entry 3193 (class 2604 OID 200242)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY agency ALTER COLUMN id SET DEFAULT nextval('agency_id_seq'::regclass);


--
-- TOC entry 3194 (class 2604 OID 200243)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY alias ALTER COLUMN id SET DEFAULT nextval('alias_id_seq'::regclass);


--
-- TOC entry 3195 (class 2604 OID 200244)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar ALTER COLUMN id SET DEFAULT nextval('calendar_id_seq'::regclass);


--
-- TOC entry 3196 (class 2604 OID 200245)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource ALTER COLUMN id SET DEFAULT nextval('calendar_datasource_id_seq'::regclass);


--
-- TOC entry 3197 (class 2604 OID 200246)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element ALTER COLUMN id SET DEFAULT nextval('calendar_element_id_seq'::regclass);


--
-- TOC entry 3198 (class 2604 OID 200247)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link ALTER COLUMN id SET DEFAULT nextval('calendar_link_id_seq'::regclass);


--
-- TOC entry 3199 (class 2604 OID 200248)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause ALTER COLUMN id SET DEFAULT nextval('change_cause_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 200249)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link ALTER COLUMN id SET DEFAULT nextval('change_cause_link_id_seq'::regclass);


--
-- TOC entry 3201 (class 2604 OID 200250)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY city ALTER COLUMN id SET DEFAULT nextval('city_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 200251)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY comment ALTER COLUMN id SET DEFAULT nextval('comment_id_seq'::regclass);


--
-- TOC entry 3203 (class 2604 OID 200252)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY datasource ALTER COLUMN id SET DEFAULT nextval('datasource_id_seq'::regclass);


--
-- TOC entry 3204 (class 2604 OID 200253)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY exception_type ALTER COLUMN id SET DEFAULT nextval('exception_type_id_seq'::regclass);


--
-- TOC entry 3205 (class 2604 OID 200254)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY export_destination ALTER COLUMN id SET DEFAULT nextval('export_destination_id_seq'::regclass);


--
-- TOC entry 3206 (class 2604 OID 200255)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_calendar ALTER COLUMN id SET DEFAULT nextval('grid_calendar_id_seq'::regclass);


--
-- TOC entry 3207 (class 2604 OID 200256)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type ALTER COLUMN id SET DEFAULT nextval('grid_link_calendar_mask_type_id_seq'::regclass);


--
-- TOC entry 3208 (class 2604 OID 200257)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_mask_type ALTER COLUMN id SET DEFAULT nextval('grid_mask_type_id_seq'::regclass);


--
-- TOC entry 3209 (class 2604 OID 200258)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line ALTER COLUMN id SET DEFAULT nextval('line_id_seq'::regclass);


--
-- TOC entry 3210 (class 2604 OID 200259)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource ALTER COLUMN id SET DEFAULT nextval('line_datasource_id_seq'::regclass);


--
-- TOC entry 3212 (class 2604 OID 200260)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version ALTER COLUMN id SET DEFAULT nextval('line_version_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 200261)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource ALTER COLUMN id SET DEFAULT nextval('line_version_datasource_id_seq'::regclass);


--
-- TOC entry 3214 (class 2604 OID 200262)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported ALTER COLUMN id SET DEFAULT nextval('line_version_not_exported_id_seq'::regclass);


--
-- TOC entry 3215 (class 2604 OID 200263)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY log ALTER COLUMN id SET DEFAULT nextval('log_id_seq'::regclass);


--
-- TOC entry 3216 (class 2604 OID 200264)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY physical_mode ALTER COLUMN id SET DEFAULT nextval('physical_mode_id_seq'::regclass);


--
-- TOC entry 3217 (class 2604 OID 200265)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi ALTER COLUMN id SET DEFAULT nextval('poi_id_seq'::regclass);


--
-- TOC entry 3218 (class 2604 OID 200266)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_address ALTER COLUMN id SET DEFAULT nextval('poi_address_id_seq'::regclass);


--
-- TOC entry 3219 (class 2604 OID 200267)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_address_datasource ALTER COLUMN id SET DEFAULT nextval('poi_address_datasource_id_seq'::regclass);


--
-- TOC entry 3220 (class 2604 OID 200268)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource ALTER COLUMN id SET DEFAULT nextval('poi_datasource_id_seq'::regclass);


--
-- TOC entry 3221 (class 2604 OID 200269)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_type ALTER COLUMN id SET DEFAULT nextval('poi_type_id_seq'::regclass);


--
-- TOC entry 3222 (class 2604 OID 200270)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY printing ALTER COLUMN id SET DEFAULT nextval('printing_id_seq'::regclass);


--
-- TOC entry 3223 (class 2604 OID 200271)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route ALTER COLUMN id SET DEFAULT nextval('route_id_seq'::regclass);


--
-- TOC entry 3224 (class 2604 OID 200272)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource ALTER COLUMN id SET DEFAULT nextval('route_datasource_id_seq'::regclass);


--
-- TOC entry 3225 (class 2604 OID 200273)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported ALTER COLUMN id SET DEFAULT nextval('route_not_exported_id_seq'::regclass);


--
-- TOC entry 3226 (class 2604 OID 200274)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section ALTER COLUMN id SET DEFAULT nextval('route_section_id_seq'::regclass);


--
-- TOC entry 3227 (class 2604 OID 200275)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop ALTER COLUMN id SET DEFAULT nextval('route_stop_id_seq'::regclass);


--
-- TOC entry 3228 (class 2604 OID 200276)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area ALTER COLUMN id SET DEFAULT nextval('stop_area_id_seq'::regclass);


--
-- TOC entry 3229 (class 2604 OID 200277)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource ALTER COLUMN id SET DEFAULT nextval('stop_area_datasource_id_seq'::regclass);


--
-- TOC entry 3230 (class 2604 OID 200278)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource ALTER COLUMN id SET DEFAULT nextval('stop_datasource_id_seq'::regclass);


--
-- TOC entry 3231 (class 2604 OID 200279)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_history ALTER COLUMN id SET DEFAULT nextval('stop_history_id_seq'::regclass);


--
-- TOC entry 3232 (class 2604 OID 200280)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time ALTER COLUMN id SET DEFAULT nextval('stop_time_id_seq'::regclass);


--
-- TOC entry 3233 (class 2604 OID 200281)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer ALTER COLUMN id SET DEFAULT nextval('transfer_id_seq'::regclass);


--
-- TOC entry 3234 (class 2604 OID 200282)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource ALTER COLUMN id SET DEFAULT nextval('transfer_datasource_id_seq'::regclass);


--
-- TOC entry 3235 (class 2604 OID 200283)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported ALTER COLUMN id SET DEFAULT nextval('transfer_not_exported_id_seq'::regclass);


--
-- TOC entry 3236 (class 2604 OID 200284)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip ALTER COLUMN id SET DEFAULT nextval('trip_id_seq'::regclass);


--
-- TOC entry 3237 (class 2604 OID 200285)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_calendar ALTER COLUMN id SET DEFAULT nextval('trip_calendar_id_seq'::regclass);


--
-- TOC entry 3238 (class 2604 OID 200286)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource ALTER COLUMN id SET DEFAULT nextval('trip_datasource_id_seq'::regclass);


--
-- TOC entry 3239 (class 2604 OID 200287)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY waypoint ALTER COLUMN id SET DEFAULT nextval('waypoint_id_seq'::regclass);


--
-- TOC entry 3241 (class 2606 OID 200289)
-- Name: agency_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY agency
    ADD CONSTRAINT agency_pk PRIMARY KEY (id);


--
-- TOC entry 3243 (class 2606 OID 200291)
-- Name: alias_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_pk PRIMARY KEY (id);


--
-- TOC entry 3247 (class 2606 OID 200293)
-- Name: calendar_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3250 (class 2606 OID 200295)
-- Name: calendar_element_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_pk PRIMARY KEY (id);


--
-- TOC entry 3254 (class 2606 OID 200297)
-- Name: calendar_link_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_pk PRIMARY KEY (id);


--
-- TOC entry 3245 (class 2606 OID 200299)
-- Name: calendar_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY calendar
    ADD CONSTRAINT calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3259 (class 2606 OID 200301)
-- Name: change_cause_link_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_pk PRIMARY KEY (id);


--
-- TOC entry 3257 (class 2606 OID 200303)
-- Name: change_cause_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY change_cause
    ADD CONSTRAINT change_cause_pk PRIMARY KEY (id);


--
-- TOC entry 3261 (class 2606 OID 200305)
-- Name: city_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pk PRIMARY KEY (id);


--
-- TOC entry 3263 (class 2606 OID 200307)
-- Name: comment_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pk PRIMARY KEY (id);


--
-- TOC entry 3265 (class 2606 OID 200309)
-- Name: datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY datasource
    ADD CONSTRAINT datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3267 (class 2606 OID 200311)
-- Name: exception_type_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY exception_type
    ADD CONSTRAINT exception_type_pk PRIMARY KEY (id);


--
-- TOC entry 3269 (class 2606 OID 200313)
-- Name: export_destination_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY export_destination
    ADD CONSTRAINT export_destination_pk PRIMARY KEY (id);


--
-- TOC entry 3271 (class 2606 OID 200315)
-- Name: export_perso_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY export_perso
    ADD CONSTRAINT export_perso_pk PRIMARY KEY (table_name);


--
-- TOC entry 3273 (class 2606 OID 200317)
-- Name: export_prod_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY export_prod
    ADD CONSTRAINT export_prod_pk PRIMARY KEY (table_name);


--
-- TOC entry 3275 (class 2606 OID 200319)
-- Name: grid_calendar_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY grid_calendar
    ADD CONSTRAINT grid_calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3277 (class 2606 OID 200321)
-- Name: grid_link_calendar_mask_type_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_pk PRIMARY KEY (id);


--
-- TOC entry 3279 (class 2606 OID 200323)
-- Name: grid_mask_type_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY grid_mask_type
    ADD CONSTRAINT grid_mask_type_pk PRIMARY KEY (id);


--
-- TOC entry 3283 (class 2606 OID 200325)
-- Name: line_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3281 (class 2606 OID 200327)
-- Name: line_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_pk PRIMARY KEY (id);


--
-- TOC entry 3287 (class 2606 OID 200329)
-- Name: line_version_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3289 (class 2606 OID 200331)
-- Name: line_version_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3285 (class 2606 OID 200333)
-- Name: line_version_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY line_version
    ADD CONSTRAINT line_version_pk PRIMARY KEY (id);


--
-- TOC entry 3291 (class 2606 OID 200335)
-- Name: log_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);


--
-- TOC entry 3293 (class 2606 OID 200337)
-- Name: non_concurrency_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_pk PRIMARY KEY (priority_line_id, non_priority_line_id);


--
-- TOC entry 3295 (class 2606 OID 200339)
-- Name: odt_area_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY odt_area
    ADD CONSTRAINT odt_area_pk PRIMARY KEY (id);


--
-- TOC entry 3297 (class 2606 OID 200341)
-- Name: odt_stop_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_pk PRIMARY KEY (odt_area_id, stop_id, start_date);


--
-- TOC entry 3299 (class 2606 OID 200343)
-- Name: physical_mode_fk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY physical_mode
    ADD CONSTRAINT physical_mode_fk PRIMARY KEY (id);


--
-- TOC entry 3307 (class 2606 OID 200345)
-- Name: poi_address_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY poi_address_datasource
    ADD CONSTRAINT poi_address_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3304 (class 2606 OID 200347)
-- Name: poi_address_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY poi_address
    ADD CONSTRAINT poi_address_pk PRIMARY KEY (id);


--
-- TOC entry 3309 (class 2606 OID 200349)
-- Name: poi_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3301 (class 2606 OID 200351)
-- Name: poi_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY poi
    ADD CONSTRAINT poi_pk PRIMARY KEY (id);


--
-- TOC entry 3311 (class 2606 OID 200353)
-- Name: poi_type_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY poi_type
    ADD CONSTRAINT poi_type_pk PRIMARY KEY (id);


--
-- TOC entry 3313 (class 2606 OID 200355)
-- Name: printing_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY printing
    ADD CONSTRAINT printing_pk PRIMARY KEY (id);


--
-- TOC entry 3319 (class 2606 OID 200357)
-- Name: route_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3315 (class 2606 OID 200359)
-- Name: route_id_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_id_pk PRIMARY KEY (id);


--
-- TOC entry 3322 (class 2606 OID 200361)
-- Name: route_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 200363)
-- Name: route_section_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_pk PRIMARY KEY (id);


--
-- TOC entry 3326 (class 2606 OID 200365)
-- Name: route_stop_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_pk PRIMARY KEY (id);


--
-- TOC entry 3334 (class 2606 OID 200367)
-- Name: stop_area_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3332 (class 2606 OID 200369)
-- Name: stop_area_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop_area
    ADD CONSTRAINT stop_area_pk PRIMARY KEY (id);


--
-- TOC entry 3337 (class 2606 OID 200371)
-- Name: stop_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3340 (class 2606 OID 200373)
-- Name: stop_history_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop_history
    ADD CONSTRAINT stop_history_pk PRIMARY KEY (id);


--
-- TOC entry 3330 (class 2606 OID 200375)
-- Name: stop_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_pk PRIMARY KEY (id);


--
-- TOC entry 3342 (class 2606 OID 200377)
-- Name: stop_time_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_pk PRIMARY KEY (id);


--
-- TOC entry 3348 (class 2606 OID 200379)
-- Name: transfer_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3350 (class 2606 OID 200381)
-- Name: transfer_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3346 (class 2606 OID 200383)
-- Name: transfer_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_pk PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 200385)
-- Name: trip_calendar_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY trip_calendar
    ADD CONSTRAINT trip_calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3358 (class 2606 OID 200387)
-- Name: trip_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3352 (class 2606 OID 200389)
-- Name: trip_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_pk PRIMARY KEY (id);


--
-- TOC entry 3361 (class 2606 OID 200391)
-- Name: waypoint_pk; Type: CONSTRAINT; Schema: public; Owner: endiv_owner; Tablespace: 
--

ALTER TABLE ONLY waypoint
    ADD CONSTRAINT waypoint_pk PRIMARY KEY (id);


--
-- TOC entry 3248 (class 1259 OID 200392)
-- Name: calendar_element_calendar_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX calendar_element_calendar_id_idx ON calendar_element USING btree (calendar_id);


--
-- TOC entry 3251 (class 1259 OID 200393)
-- Name: calendar_link_day_calendar_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX calendar_link_day_calendar_id_idx ON calendar_link USING btree (day_calendar_id);


--
-- TOC entry 3252 (class 1259 OID 200394)
-- Name: calendar_link_period_calendar_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX calendar_link_period_calendar_id_idx ON calendar_link USING btree (period_calendar_id);


--
-- TOC entry 3255 (class 1259 OID 200395)
-- Name: calendar_link_trip_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX calendar_link_trip_id_idx ON calendar_link USING btree (trip_id);


--
-- TOC entry 3305 (class 1259 OID 200396)
-- Name: poi_address_poi_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX poi_address_poi_id_idx ON poi_address USING btree (poi_id);


--
-- TOC entry 3302 (class 1259 OID 200397)
-- Name: poi_poi_type_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX poi_poi_type_id_idx ON poi USING btree (poi_type_id);


--
-- TOC entry 3317 (class 1259 OID 200398)
-- Name: route_datasource_code_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX route_datasource_code_idx ON route_datasource USING btree (code);


--
-- TOC entry 3320 (class 1259 OID 200399)
-- Name: route_datasource_route_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX route_datasource_route_id_idx ON route_datasource USING btree (route_id);


--
-- TOC entry 3316 (class 1259 OID 200400)
-- Name: route_line_version_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX route_line_version_id_idx ON route USING btree (line_version_id);


--
-- TOC entry 3327 (class 1259 OID 200401)
-- Name: route_stop_route_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX route_stop_route_id_idx ON route_stop USING btree (route_id);


--
-- TOC entry 3328 (class 1259 OID 200402)
-- Name: route_stop_waypoint_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX route_stop_waypoint_id_idx ON route_stop USING btree (waypoint_id);


--
-- TOC entry 3335 (class 1259 OID 200403)
-- Name: stop_datasource_code_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX stop_datasource_code_idx ON stop_datasource USING btree (code);


--
-- TOC entry 3338 (class 1259 OID 200404)
-- Name: stop_datasource_stop_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX stop_datasource_stop_id_idx ON stop_datasource USING btree (stop_id);


--
-- TOC entry 3343 (class 1259 OID 200405)
-- Name: stop_time_route_stop_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX stop_time_route_stop_id_idx ON stop_time USING btree (route_stop_id);


--
-- TOC entry 3344 (class 1259 OID 200406)
-- Name: stop_time_trip_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX stop_time_trip_id_idx ON stop_time USING btree (trip_id);


--
-- TOC entry 3356 (class 1259 OID 200407)
-- Name: trip_datasource_code_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX trip_datasource_code_idx ON trip_datasource USING btree (code);


--
-- TOC entry 3359 (class 1259 OID 200408)
-- Name: trip_datasource_trip_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX trip_datasource_trip_id_idx ON trip_datasource USING btree (trip_id);


--
-- TOC entry 3353 (class 1259 OID 200409)
-- Name: trip_route_id_idx; Type: INDEX; Schema: public; Owner: endiv_owner; Tablespace: 
--

CREATE INDEX trip_route_id_idx ON trip USING btree (route_id);


--
-- TOC entry 3362 (class 2606 OID 200410)
-- Name: alias_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3363 (class 2606 OID 200415)
-- Name: calendar_datasource_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3364 (class 2606 OID 200420)
-- Name: calendar_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3365 (class 2606 OID 200425)
-- Name: calendar_element_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3366 (class 2606 OID 200430)
-- Name: calendar_element_included_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_included_calendar_id_fk FOREIGN KEY (included_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3367 (class 2606 OID 200435)
-- Name: calendar_link_day_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_day_calendar_id_fk FOREIGN KEY (day_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3368 (class 2606 OID 200440)
-- Name: calendar_link_period_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_period_calendar_id_fk FOREIGN KEY (period_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3369 (class 2606 OID 200445)
-- Name: calendar_link_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3370 (class 2606 OID 200450)
-- Name: change_cause_link_change_cause_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_change_cause_id_fk FOREIGN KEY (change_cause_id) REFERENCES change_cause(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3371 (class 2606 OID 200455)
-- Name: change_cause_link_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3372 (class 2606 OID 200460)
-- Name: city_main_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_main_stop_area_id_fk FOREIGN KEY (main_stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3373 (class 2606 OID 200465)
-- Name: datasource_id_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY datasource
    ADD CONSTRAINT datasource_id_agency_fk FOREIGN KEY (agency_id) REFERENCES agency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3428 (class 2606 OID 200470)
-- Name: grid_calendar_grid_mask_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_calendar
    ADD CONSTRAINT grid_calendar_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3374 (class 2606 OID 200475)
-- Name: grid_calendar_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_calendar
    ADD CONSTRAINT grid_calendar_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3375 (class 2606 OID 200480)
-- Name: grid_link_calendar_mask_type_grid_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_grid_calendar_id_fk FOREIGN KEY (grid_calendar_id) REFERENCES grid_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3376 (class 2606 OID 200485)
-- Name: grid_link_calendar_mask_type_grid_mask_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3378 (class 2606 OID 200490)
-- Name: line_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3379 (class 2606 OID 200495)
-- Name: line_datasource_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3377 (class 2606 OID 200500)
-- Name: line_physical_mode_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_physical_mode_fk FOREIGN KEY (physical_mode_id) REFERENCES physical_mode(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3381 (class 2606 OID 200505)
-- Name: line_version_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3382 (class 2606 OID 200510)
-- Name: line_version_datasource_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3380 (class 2606 OID 200515)
-- Name: line_version_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version
    ADD CONSTRAINT line_version_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3383 (class 2606 OID 200520)
-- Name: line_version_not_exported_export_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3384 (class 2606 OID 200525)
-- Name: line_version_not_exported_line_version_id_pk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_line_version_id_pk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3385 (class 2606 OID 200530)
-- Name: non_concurrency_non_priority_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_non_priority_line_id_fk FOREIGN KEY (non_priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3386 (class 2606 OID 200535)
-- Name: non_concurrency_priority_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_priority_line_id_fk FOREIGN KEY (priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3387 (class 2606 OID 200540)
-- Name: odt_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_area
    ADD CONSTRAINT odt_area_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3388 (class 2606 OID 200545)
-- Name: odt_stop_odt_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_odt_area_id_fk FOREIGN KEY (odt_area_id) REFERENCES odt_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3389 (class 2606 OID 200550)
-- Name: odt_stop_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3392 (class 2606 OID 200555)
-- Name: poi_address_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_address_datasource
    ADD CONSTRAINT poi_address_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3393 (class 2606 OID 200560)
-- Name: poi_address_datasource_poi_address_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_address_datasource
    ADD CONSTRAINT poi_address_datasource_poi_address_id_fk FOREIGN KEY (poi_address_id) REFERENCES poi_address(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3391 (class 2606 OID 200565)
-- Name: poi_address_poi_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_address
    ADD CONSTRAINT poi_address_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3394 (class 2606 OID 200570)
-- Name: poi_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3395 (class 2606 OID 200575)
-- Name: poi_datasource_poi_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3390 (class 2606 OID 200580)
-- Name: poi_poi_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi
    ADD CONSTRAINT poi_poi_type_id_fk FOREIGN KEY (poi_type_id) REFERENCES poi_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3396 (class 2606 OID 200585)
-- Name: printing_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY printing
    ADD CONSTRAINT printing_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3397 (class 2606 OID 200590)
-- Name: route_comment_id; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_comment_id FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3399 (class 2606 OID 200595)
-- Name: route_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3400 (class 2606 OID 200600)
-- Name: route_datasource_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3398 (class 2606 OID 200605)
-- Name: route_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3401 (class 2606 OID 200610)
-- Name: route_not_exported_export_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3402 (class 2606 OID 200615)
-- Name: route_not_exported_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3403 (class 2606 OID 200620)
-- Name: route_section_end_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3404 (class 2606 OID 200625)
-- Name: route_section_start_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3405 (class 2606 OID 200630)
-- Name: route_stop_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3406 (class 2606 OID 200635)
-- Name: route_stop_route_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_route_section_id_fk FOREIGN KEY (route_section_id) REFERENCES route_section(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3407 (class 2606 OID 200640)
-- Name: route_stop_waypoint_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_waypoint_id_fk FOREIGN KEY (waypoint_id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3411 (class 2606 OID 200645)
-- Name: stop_area_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area
    ADD CONSTRAINT stop_area_city_id_fk FOREIGN KEY (city_id) REFERENCES city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3412 (class 2606 OID 200650)
-- Name: stop_area_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3413 (class 2606 OID 200655)
-- Name: stop_area_datasource_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3414 (class 2606 OID 200660)
-- Name: stop_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3415 (class 2606 OID 200665)
-- Name: stop_datasource_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3416 (class 2606 OID 200670)
-- Name: stop_history_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_history
    ADD CONSTRAINT stop_history_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3408 (class 2606 OID 200675)
-- Name: stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3409 (class 2606 OID 200680)
-- Name: stop_master_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_master_stop_id_fk FOREIGN KEY (master_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3410 (class 2606 OID 200685)
-- Name: stop_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3417 (class 2606 OID 200690)
-- Name: stop_time_route_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_route_stop_id_fk FOREIGN KEY (route_stop_id) REFERENCES route_stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3418 (class 2606 OID 200695)
-- Name: stop_time_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3421 (class 2606 OID 200700)
-- Name: transfer_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3422 (class 2606 OID 200705)
-- Name: transfer_datasource_transfer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3419 (class 2606 OID 200710)
-- Name: transfer_end_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3423 (class 2606 OID 200715)
-- Name: transfer_not_exported_exporte_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_exporte_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3424 (class 2606 OID 200720)
-- Name: transfer_not_exported_transfer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3420 (class 2606 OID 200725)
-- Name: transfer_start_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3425 (class 2606 OID 200730)
-- Name: trip_comment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_comment_id_fk FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3429 (class 2606 OID 200735)
-- Name: trip_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3430 (class 2606 OID 200740)
-- Name: trip_datasource_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3426 (class 2606 OID 200745)
-- Name: trip_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3427 (class 2606 OID 200750)
-- Name: trip_trip_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_trip_calendar_id_fk FOREIGN KEY (trip_calendar_id) REFERENCES trip_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;