--
-- TOC entry 274 (class 3079 OID 11691)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 274
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 275 (class 3079 OID 83269)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 275
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 84384)
-- Name: agency; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 175 (class 1259 OID 84387)
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
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 175
-- Name: agency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE agency_id_seq OWNED BY agency.id;


--
-- TOC entry 176 (class 1259 OID 84389)
-- Name: alias; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alias (
    id integer NOT NULL,
    stop_area_id integer,
    name character varying(255)
);


ALTER TABLE public.alias OWNER TO endiv_owner;

--
-- TOC entry 177 (class 1259 OID 84392)
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
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 177
-- Name: alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE alias_id_seq OWNED BY alias.id;


--
-- TOC entry 178 (class 1259 OID 84394)
-- Name: calendar; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    calendar_type integer NOT NULL
);


ALTER TABLE public.calendar OWNER TO endiv_owner;

--
-- TOC entry 179 (class 1259 OID 84397)
-- Name: calendar_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_datasource (
    id integer NOT NULL,
    calendar_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.calendar_datasource OWNER TO endiv_owner;

--
-- TOC entry 180 (class 1259 OID 84400)
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
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 180
-- Name: calendar_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_datasource_id_seq OWNED BY calendar_datasource.id;


--
-- TOC entry 181 (class 1259 OID 84402)
-- Name: calendar_element; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN calendar_element.id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN calendar_element.id IS '
';


--
-- TOC entry 182 (class 1259 OID 84405)
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
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 182
-- Name: calendar_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_element_id_seq OWNED BY calendar_element.id;


--
-- TOC entry 183 (class 1259 OID 84407)
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
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 183
-- Name: calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_id_seq OWNED BY calendar.id;


--
-- TOC entry 184 (class 1259 OID 84409)
-- Name: calendar_link; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_link (
    id integer NOT NULL,
    trip_id integer NOT NULL,
    day_calendar_id integer NOT NULL,
    period_calendar_id integer NOT NULL
);


ALTER TABLE public.calendar_link OWNER TO endiv_owner;

--
-- TOC entry 185 (class 1259 OID 84412)
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
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 185
-- Name: calendar_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE calendar_link_id_seq OWNED BY calendar_link.id;


--
-- TOC entry 186 (class 1259 OID 84414)
-- Name: change_cause; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE change_cause (
    id integer NOT NULL,
    description character varying(255)
);


ALTER TABLE public.change_cause OWNER TO endiv_owner;

--
-- TOC entry 187 (class 1259 OID 84417)
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
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 187
-- Name: change_cause_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE change_cause_id_seq OWNED BY change_cause.id;


--
-- TOC entry 188 (class 1259 OID 84419)
-- Name: change_cause_link; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE change_cause_link (
    id integer NOT NULL,
    change_cause_id integer,
    line_version_id integer
);


ALTER TABLE public.change_cause_link OWNER TO endiv_owner;

--
-- TOC entry 189 (class 1259 OID 84422)
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
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 189
-- Name: change_cause_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE change_cause_link_id_seq OWNED BY change_cause_link.id;


--
-- TOC entry 190 (class 1259 OID 84424)
-- Name: city; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE city (
    id integer NOT NULL,
    insee character varying(5) NOT NULL,
    name character varying(255) NOT NULL,
    main_stop_area_id integer
);


ALTER TABLE public.city OWNER TO endiv_owner;

--
-- TOC entry 191 (class 1259 OID 84427)
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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 191
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE city_id_seq OWNED BY city.id;


--
-- TOC entry 192 (class 1259 OID 84429)
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comment (
    id integer NOT NULL,
    label character varying(5),
    comment_text character varying(255)
);


ALTER TABLE public.comment OWNER TO endiv_owner;

--
-- TOC entry 193 (class 1259 OID 84432)
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
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 193
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE comment_id_seq OWNED BY comment.id;


--
-- TOC entry 194 (class 1259 OID 84434)
-- Name: datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE datasource (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    agency_id integer NOT NULL
);


ALTER TABLE public.datasource OWNER TO endiv_owner;

--
-- TOC entry 195 (class 1259 OID 84437)
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
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 195
-- Name: datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE datasource_id_seq OWNED BY datasource.id;


--
-- TOC entry 196 (class 1259 OID 84439)
-- Name: exception_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 197 (class 1259 OID 84442)
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
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 197
-- Name: exception_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE exception_type_id_seq OWNED BY exception_type.id;


--
-- TOC entry 267 (class 1259 OID 85115)
-- Name: export_destination; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE export_destination (
    id integer NOT NULL,
    nom character varying(255),
    url text
);


ALTER TABLE public.export_destination OWNER TO endiv_owner;

--
-- TOC entry 266 (class 1259 OID 85113)
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
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 266
-- Name: export_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE export_destination_id_seq OWNED BY export_destination.id;


--
-- TOC entry 198 (class 1259 OID 84444)
-- Name: export_perso; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE export_perso (
    table_name character varying(30) NOT NULL
);


ALTER TABLE public.export_perso OWNER TO endiv_owner;

--
-- TOC entry 199 (class 1259 OID 84447)
-- Name: export_prod; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE export_prod (
    table_name character varying(30) NOT NULL
);


ALTER TABLE public.export_prod OWNER TO endiv_owner;

--
-- TOC entry 200 (class 1259 OID 84450)
-- Name: grid_calendar; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE grid_calendar (
    id integer NOT NULL,
    line_version_id integer,
    name character varying(255) NOT NULL,
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
-- TOC entry 201 (class 1259 OID 84453)
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
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 201
-- Name: grid_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_calendar_id_seq OWNED BY grid_calendar.id;


--
-- TOC entry 202 (class 1259 OID 84455)
-- Name: grid_link_calendar_mask_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE grid_link_calendar_mask_type (
    id integer NOT NULL,
    grid_calendar_id integer NOT NULL,
    grid_mask_type_id integer NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.grid_link_calendar_mask_type OWNER TO endiv_owner;

--
-- TOC entry 203 (class 1259 OID 84458)
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
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 203
-- Name: grid_link_calendar_mask_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_link_calendar_mask_type_id_seq OWNED BY grid_link_calendar_mask_type.id;


--
-- TOC entry 204 (class 1259 OID 84460)
-- Name: grid_mask_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE grid_mask_type (
    id integer NOT NULL,
    calendar_type character varying(25),
    calendar_period character varying(25)
);


ALTER TABLE public.grid_mask_type OWNER TO endiv_owner;

--
-- TOC entry 205 (class 1259 OID 84463)
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
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 205
-- Name: grid_mask_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE grid_mask_type_id_seq OWNED BY grid_mask_type.id;


--
-- TOC entry 206 (class 1259 OID 84465)
-- Name: line; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE line (
    id integer NOT NULL,
    number character varying(10) NOT NULL,
    physical_mode_id integer NOT NULL
);


ALTER TABLE public.line OWNER TO endiv_owner;

--
-- TOC entry 207 (class 1259 OID 84468)
-- Name: line_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE line_datasource (
    id integer NOT NULL,
    line_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.line_datasource OWNER TO endiv_owner;

--
-- TOC entry 208 (class 1259 OID 84471)
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
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 208
-- Name: line_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_datasource_id_seq OWNED BY line_datasource.id;


--
-- TOC entry 209 (class 1259 OID 84473)
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
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 209
-- Name: line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_id_seq OWNED BY line.id;


--
-- TOC entry 210 (class 1259 OID 84475)
-- Name: line_version; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
    bg_color character varying(20) NOT NULL,
    bg_hexa_color character varying(6) NOT NULL,
    fg_color character varying(20) NOT NULL,
    fg_hexa_color character varying(6) NOT NULL,
    carto_file text,
    accessibility boolean NOT NULL,
    air_conditioned boolean NOT NULL,
    certified boolean NOT NULL default false,
    comment text,
    depot character varying(50)
);


ALTER TABLE public.line_version OWNER TO endiv_owner;

--
-- TOC entry 211 (class 1259 OID 84481)
-- Name: line_version_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE line_version_datasource (
    id integer NOT NULL,
    line_version_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.line_version_datasource OWNER TO endiv_owner;

--
-- TOC entry 212 (class 1259 OID 84484)
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
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 212
-- Name: line_version_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_datasource_id_seq OWNED BY line_version_datasource.id;


--
-- TOC entry 213 (class 1259 OID 84486)
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
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 213
-- Name: line_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_id_seq OWNED BY line_version.id;


--
-- TOC entry 269 (class 1259 OID 85126)
-- Name: line_version_not_exported; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE line_version_not_exported (
    id integer NOT NULL,
    line_version_id integer,
    export_destination_id integer
);


ALTER TABLE public.line_version_not_exported OWNER TO endiv_owner;

--
-- TOC entry 268 (class 1259 OID 85124)
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
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 268
-- Name: line_version_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE line_version_not_exported_id_seq OWNED BY line_version_not_exported.id;


--
-- TOC entry 214 (class 1259 OID 84488)
-- Name: log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 215 (class 1259 OID 84494)
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
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 215
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE log_id_seq OWNED BY log.id;


--
-- TOC entry 216 (class 1259 OID 84496)
-- Name: non_concurrency; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE non_concurrency (
    priority_line_id integer NOT NULL,
    non_priority_line_id integer NOT NULL,
    "time" integer NOT NULL
);


ALTER TABLE public.non_concurrency OWNER TO endiv_owner;

--
-- TOC entry 217 (class 1259 OID 84499)
-- Name: odt_area; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odt_area (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    comment text
);


ALTER TABLE public.odt_area OWNER TO endiv_owner;

--
-- TOC entry 218 (class 1259 OID 84505)
-- Name: odt_stop; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 219 (class 1259 OID 84508)
-- Name: physical_mode; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE physical_mode (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    type character varying(30) NOT NULL
);


ALTER TABLE public.physical_mode OWNER TO endiv_owner;

--
-- TOC entry 220 (class 1259 OID 84511)
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
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 220
-- Name: physical_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE physical_mode_id_seq OWNED BY physical_mode.id;


--
-- TOC entry 221 (class 1259 OID 84513)
-- Name: poi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 222 (class 1259 OID 84516)
-- Name: poi_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE poi_datasource (
    id integer NOT NULL,
    poi_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.poi_datasource OWNER TO endiv_owner;

--
-- TOC entry 223 (class 1259 OID 84519)
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
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 223
-- Name: poi_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_datasource_id_seq OWNED BY poi_datasource.id;


--
-- TOC entry 224 (class 1259 OID 84521)
-- Name: poi_adress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE poi_adress (
    id integer NOT NULL,
    poi_id integer NOT NULL,
    adress text,
    is_entrance boolean NOT NULL,
    the_geom geometry(Point,3943) NOT NULL
);


ALTER TABLE public.poi_adress OWNER TO endiv_owner;

--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN poi_adress.id; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi_adress.id IS '
';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN poi_adress.adress; Type: COMMENT; Schema: public; Owner: endiv_owner
--

COMMENT ON COLUMN poi_adress.adress IS '
';


--
-- TOC entry 225 (class 1259 OID 84527)
-- Name: poi_adress_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE poi_adress_datasource (
    id integer NOT NULL,
    poi_adress_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.poi_adress_datasource OWNER TO endiv_owner;

--
-- TOC entry 226 (class 1259 OID 84530)
-- Name: poi_adress_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_adress_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_adress_datasource_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 226
-- Name: poi_adress_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_adress_datasource_id_seq OWNED BY poi_adress_datasource.id;


--
-- TOC entry 227 (class 1259 OID 84532)
-- Name: poi_adress_id_seq; Type: SEQUENCE; Schema: public; Owner: endiv_owner
--

CREATE SEQUENCE poi_adress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_adress_id_seq OWNER TO endiv_owner;

--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 227
-- Name: poi_adress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_adress_id_seq OWNED BY poi_adress.id;


--
-- TOC entry 228 (class 1259 OID 84534)
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
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 228
-- Name: poi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_id_seq OWNED BY poi.id;


--
-- TOC entry 229 (class 1259 OID 84536)
-- Name: poi_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE poi_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.poi_type OWNER TO endiv_owner;

--
-- TOC entry 230 (class 1259 OID 84539)
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
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 230
-- Name: poi_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE poi_type_id_seq OWNED BY poi_type.id;


--
-- TOC entry 231 (class 1259 OID 84541)
-- Name: printing; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 232 (class 1259 OID 84547)
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
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 232
-- Name: printing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE printing_id_seq OWNED BY printing.id;


--
-- TOC entry 233 (class 1259 OID 84549)
-- Name: route; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 234 (class 1259 OID 84552)
-- Name: route_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE route_datasource (
    id integer NOT NULL,
    route_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.route_datasource OWNER TO endiv_owner;

--
-- TOC entry 235 (class 1259 OID 84555)
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
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 235
-- Name: route_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_datasource_id_seq OWNED BY route_datasource.id;


--
-- TOC entry 236 (class 1259 OID 84557)
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
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 236
-- Name: route_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_id_seq OWNED BY route.id;


--
-- TOC entry 271 (class 1259 OID 85144)
-- Name: route_not_exported; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE route_not_exported (
    id integer NOT NULL,
    route_id integer,
    export_destination_id integer
);


ALTER TABLE public.route_not_exported OWNER TO endiv_owner;

--
-- TOC entry 270 (class 1259 OID 85142)
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
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 270
-- Name: route_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_not_exported_id_seq OWNED BY route_not_exported.id;


--
-- TOC entry 237 (class 1259 OID 84559)
-- Name: route_section; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 238 (class 1259 OID 84565)
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
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 238
-- Name: route_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_section_id_seq OWNED BY route_section.id;


--
-- TOC entry 239 (class 1259 OID 84567)
-- Name: route_stop; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 240 (class 1259 OID 84570)
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
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 240
-- Name: route_stop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE route_stop_id_seq OWNED BY route_stop.id;


--
-- TOC entry 243 (class 1259 OID 84577)
-- Name: stop; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stop (
    id integer NOT NULL,
    stop_area_id integer NOT NULL,
    master_stop_id integer
);


ALTER TABLE public.stop OWNER TO endiv_owner;

--
-- TOC entry 244 (class 1259 OID 84580)
-- Name: stop_area; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 245 (class 1259 OID 84586)
-- Name: stop_area_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stop_area_datasource (
    id integer NOT NULL,
    stop_area_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.stop_area_datasource OWNER TO endiv_owner;

--
-- TOC entry 246 (class 1259 OID 84589)
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
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 246
-- Name: stop_area_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_area_datasource_id_seq OWNED BY stop_area_datasource.id;


--
-- TOC entry 247 (class 1259 OID 84591)
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
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 247
-- Name: stop_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_area_id_seq OWNED BY stop_area.id;


--
-- TOC entry 248 (class 1259 OID 84593)
-- Name: stop_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stop_datasource (
    id integer NOT NULL,
    stop_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.stop_datasource OWNER TO endiv_owner;

--
-- TOC entry 249 (class 1259 OID 84596)
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
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 249
-- Name: stop_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_datasource_id_seq OWNED BY stop_datasource.id;


--
-- TOC entry 250 (class 1259 OID 84598)
-- Name: stop_history; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 251 (class 1259 OID 84604)
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
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 251
-- Name: stop_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_history_id_seq OWNED BY stop_history.id;


--
-- TOC entry 252 (class 1259 OID 84606)
-- Name: stop_time; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 253 (class 1259 OID 84609)
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
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 253
-- Name: stop_time_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE stop_time_id_seq OWNED BY stop_time.id;


--
-- TOC entry 254 (class 1259 OID 84611)
-- Name: transfer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 255 (class 1259 OID 84617)
-- Name: transfer_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE transfer_datasource (
    id integer NOT NULL,
    transfer_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.transfer_datasource OWNER TO endiv_owner;

--
-- TOC entry 256 (class 1259 OID 84620)
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
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 256
-- Name: transfer_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_datasource_id_seq OWNED BY transfer_datasource.id;


--
-- TOC entry 257 (class 1259 OID 84622)
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
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 257
-- Name: transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_id_seq OWNED BY transfer.id;


--
-- TOC entry 273 (class 1259 OID 85162)
-- Name: transfer_not_exported; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE transfer_not_exported (
    id integer NOT NULL,
    transfer_id integer,
    export_destination_id integer
);


ALTER TABLE public.transfer_not_exported OWNER TO endiv_owner;

--
-- TOC entry 272 (class 1259 OID 85160)
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
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 272
-- Name: transfer_not_exported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE transfer_not_exported_id_seq OWNED BY transfer_not_exported.id;


--
-- TOC entry 258 (class 1259 OID 84624)
-- Name: trip; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 259 (class 1259 OID 84627)
-- Name: trip_calendar; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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
-- TOC entry 262 (class 1259 OID 84638)
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
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 262
-- Name: trip_calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_calendar_id_seq OWNED BY trip_calendar.id;


--
-- TOC entry 263 (class 1259 OID 84640)
-- Name: trip_datasource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE trip_datasource (
    id integer NOT NULL,
    trip_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);


ALTER TABLE public.trip_datasource OWNER TO endiv_owner;

--
-- TOC entry 264 (class 1259 OID 84643)
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
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 264
-- Name: trip_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_datasource_id_seq OWNED BY trip_datasource.id;


--
-- TOC entry 265 (class 1259 OID 84645)
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
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 265
-- Name: trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE trip_id_seq OWNED BY trip.id;


--
-- TOC entry 241 (class 1259 OID 84572)
-- Name: waypoint; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE waypoint (
    id integer NOT NULL
);


ALTER TABLE public.waypoint OWNER TO endiv_owner;

--
-- TOC entry 242 (class 1259 OID 84575)
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
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 242
-- Name: waypoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: endiv_owner
--

ALTER SEQUENCE waypoint_id_seq OWNED BY waypoint.id;


--
-- TOC entry 3182 (class 2604 OID 84647)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY agency ALTER COLUMN id SET DEFAULT nextval('agency_id_seq'::regclass);


--
-- TOC entry 3183 (class 2604 OID 84648)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY alias ALTER COLUMN id SET DEFAULT nextval('alias_id_seq'::regclass);


--
-- TOC entry 3184 (class 2604 OID 84649)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar ALTER COLUMN id SET DEFAULT nextval('calendar_id_seq'::regclass);


--
-- TOC entry 3185 (class 2604 OID 84650)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource ALTER COLUMN id SET DEFAULT nextval('calendar_datasource_id_seq'::regclass);


--
-- TOC entry 3186 (class 2604 OID 84651)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element ALTER COLUMN id SET DEFAULT nextval('calendar_element_id_seq'::regclass);


--
-- TOC entry 3187 (class 2604 OID 84652)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link ALTER COLUMN id SET DEFAULT nextval('calendar_link_id_seq'::regclass);


--
-- TOC entry 3188 (class 2604 OID 84653)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause ALTER COLUMN id SET DEFAULT nextval('change_cause_id_seq'::regclass);


--
-- TOC entry 3189 (class 2604 OID 84654)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link ALTER COLUMN id SET DEFAULT nextval('change_cause_link_id_seq'::regclass);


--
-- TOC entry 3190 (class 2604 OID 84655)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY city ALTER COLUMN id SET DEFAULT nextval('city_id_seq'::regclass);


--
-- TOC entry 3191 (class 2604 OID 84656)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY comment ALTER COLUMN id SET DEFAULT nextval('comment_id_seq'::regclass);


--
-- TOC entry 3192 (class 2604 OID 84657)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY datasource ALTER COLUMN id SET DEFAULT nextval('datasource_id_seq'::regclass);


--
-- TOC entry 3193 (class 2604 OID 84658)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY exception_type ALTER COLUMN id SET DEFAULT nextval('exception_type_id_seq'::regclass);


--
-- TOC entry 3225 (class 2604 OID 85118)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY export_destination ALTER COLUMN id SET DEFAULT nextval('export_destination_id_seq'::regclass);


--
-- TOC entry 3194 (class 2604 OID 84659)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_calendar ALTER COLUMN id SET DEFAULT nextval('grid_calendar_id_seq'::regclass);


--
-- TOC entry 3195 (class 2604 OID 84660)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type ALTER COLUMN id SET DEFAULT nextval('grid_link_calendar_mask_type_id_seq'::regclass);


--
-- TOC entry 3196 (class 2604 OID 84661)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_mask_type ALTER COLUMN id SET DEFAULT nextval('grid_mask_type_id_seq'::regclass);


--
-- TOC entry 3197 (class 2604 OID 84662)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line ALTER COLUMN id SET DEFAULT nextval('line_id_seq'::regclass);


--
-- TOC entry 3198 (class 2604 OID 84663)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource ALTER COLUMN id SET DEFAULT nextval('line_datasource_id_seq'::regclass);


--
-- TOC entry 3199 (class 2604 OID 84664)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version ALTER COLUMN id SET DEFAULT nextval('line_version_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 84665)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource ALTER COLUMN id SET DEFAULT nextval('line_version_datasource_id_seq'::regclass);


--
-- TOC entry 3226 (class 2604 OID 85129)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported ALTER COLUMN id SET DEFAULT nextval('line_version_not_exported_id_seq'::regclass);


--
-- TOC entry 3201 (class 2604 OID 84666)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY log ALTER COLUMN id SET DEFAULT nextval('log_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 84667)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY physical_mode ALTER COLUMN id SET DEFAULT nextval('physical_mode_id_seq'::regclass);


--
-- TOC entry 3203 (class 2604 OID 84668)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi ALTER COLUMN id SET DEFAULT nextval('poi_id_seq'::regclass);


--
-- TOC entry 3204 (class 2604 OID 84669)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource ALTER COLUMN id SET DEFAULT nextval('poi_datasource_id_seq'::regclass);


--
-- TOC entry 3205 (class 2604 OID 84670)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_adress ALTER COLUMN id SET DEFAULT nextval('poi_adress_id_seq'::regclass);


--
-- TOC entry 3206 (class 2604 OID 84671)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_adress_datasource ALTER COLUMN id SET DEFAULT nextval('poi_adress_datasource_id_seq'::regclass);


--
-- TOC entry 3207 (class 2604 OID 84672)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_type ALTER COLUMN id SET DEFAULT nextval('poi_type_id_seq'::regclass);


--
-- TOC entry 3208 (class 2604 OID 84673)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY printing ALTER COLUMN id SET DEFAULT nextval('printing_id_seq'::regclass);


--
-- TOC entry 3209 (class 2604 OID 84674)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route ALTER COLUMN id SET DEFAULT nextval('route_id_seq'::regclass);


--
-- TOC entry 3210 (class 2604 OID 84675)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource ALTER COLUMN id SET DEFAULT nextval('route_datasource_id_seq'::regclass);


--
-- TOC entry 3227 (class 2604 OID 85147)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported ALTER COLUMN id SET DEFAULT nextval('route_not_exported_id_seq'::regclass);


--
-- TOC entry 3211 (class 2604 OID 84676)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section ALTER COLUMN id SET DEFAULT nextval('route_section_id_seq'::regclass);


--
-- TOC entry 3212 (class 2604 OID 84677)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop ALTER COLUMN id SET DEFAULT nextval('route_stop_id_seq'::regclass);


--
-- TOC entry 3214 (class 2604 OID 84679)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area ALTER COLUMN id SET DEFAULT nextval('stop_area_id_seq'::regclass);


--
-- TOC entry 3215 (class 2604 OID 84680)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource ALTER COLUMN id SET DEFAULT nextval('stop_area_datasource_id_seq'::regclass);


--
-- TOC entry 3216 (class 2604 OID 84681)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource ALTER COLUMN id SET DEFAULT nextval('stop_datasource_id_seq'::regclass);


--
-- TOC entry 3217 (class 2604 OID 84682)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_history ALTER COLUMN id SET DEFAULT nextval('stop_history_id_seq'::regclass);


--
-- TOC entry 3218 (class 2604 OID 84683)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time ALTER COLUMN id SET DEFAULT nextval('stop_time_id_seq'::regclass);


--
-- TOC entry 3219 (class 2604 OID 84684)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer ALTER COLUMN id SET DEFAULT nextval('transfer_id_seq'::regclass);


--
-- TOC entry 3220 (class 2604 OID 84685)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource ALTER COLUMN id SET DEFAULT nextval('transfer_datasource_id_seq'::regclass);


--
-- TOC entry 3228 (class 2604 OID 85165)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported ALTER COLUMN id SET DEFAULT nextval('transfer_not_exported_id_seq'::regclass);


--
-- TOC entry 3221 (class 2604 OID 84686)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip ALTER COLUMN id SET DEFAULT nextval('trip_id_seq'::regclass);


--
-- TOC entry 3222 (class 2604 OID 84687)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_calendar ALTER COLUMN id SET DEFAULT nextval('trip_calendar_id_seq'::regclass);




--
-- TOC entry 3224 (class 2604 OID 84689)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource ALTER COLUMN id SET DEFAULT nextval('trip_datasource_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 84678)
-- Name: id; Type: DEFAULT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY waypoint ALTER COLUMN id SET DEFAULT nextval('waypoint_id_seq'::regclass);


--
-- TOC entry 3230 (class 2606 OID 84691)
-- Name: agency_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agency
    ADD CONSTRAINT agency_pk PRIMARY KEY (id);


--
-- TOC entry 3232 (class 2606 OID 84693)
-- Name: alias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_pk PRIMARY KEY (id);


--
-- TOC entry 3236 (class 2606 OID 84695)
-- Name: calendar_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3238 (class 2606 OID 84697)
-- Name: calendar_element_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_pk PRIMARY KEY (id);


--
-- TOC entry 3240 (class 2606 OID 84699)
-- Name: calendar_link_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_pk PRIMARY KEY (id);


--
-- TOC entry 3234 (class 2606 OID 84701)
-- Name: calendar_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar
    ADD CONSTRAINT calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3244 (class 2606 OID 84703)
-- Name: change_cause_link_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_pk PRIMARY KEY (id);


--
-- TOC entry 3242 (class 2606 OID 84705)
-- Name: change_cause_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY change_cause
    ADD CONSTRAINT change_cause_pk PRIMARY KEY (id);


--
-- TOC entry 3246 (class 2606 OID 84707)
-- Name: city_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pk PRIMARY KEY (id);


--
-- TOC entry 3248 (class 2606 OID 84709)
-- Name: comment_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pk PRIMARY KEY (id);


--
-- TOC entry 3250 (class 2606 OID 84711)
-- Name: datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datasource
    ADD CONSTRAINT datasource_pk PRIMARY KEY (id);


-- Name: exception_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY exception_type
    ADD CONSTRAINT exception_type_pk PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 85123)
-- Name: export_destination_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY export_destination
    ADD CONSTRAINT export_destination_pk PRIMARY KEY (id);


--
-- TOC entry 3252 (class 2606 OID 84713)
-- Name: export_perso_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY export_perso
    ADD CONSTRAINT export_perso_pk PRIMARY KEY (table_name);


--
-- TOC entry 3254 (class 2606 OID 84715)
-- Name: export_prod_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY export_prod
    ADD CONSTRAINT export_prod_pk PRIMARY KEY (table_name);


--
-- TOC entry 3256 (class 2606 OID 84717)
-- Name: grid_calendar_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY grid_calendar
    ADD CONSTRAINT grid_calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3258 (class 2606 OID 84719)
-- Name: grid_link_calendar_mask_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_pk PRIMARY KEY (id);


--
-- TOC entry 3260 (class 2606 OID 84721)
-- Name: grid_mask_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY grid_mask_type
    ADD CONSTRAINT grid_mask_type_pk PRIMARY KEY (id);


--
-- TOC entry 3264 (class 2606 OID 84723)
-- Name: line_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3262 (class 2606 OID 84725)
-- Name: line_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_pk PRIMARY KEY (id);


--
-- TOC entry 3268 (class 2606 OID 84727)
-- Name: line_version_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3326 (class 2606 OID 85131)
-- Name: line_version_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3266 (class 2606 OID 84729)
-- Name: line_version_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY line_version
    ADD CONSTRAINT line_version_pk PRIMARY KEY (id);


-- Name: log_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);


--
-- TOC entry 3270 (class 2606 OID 84731)
-- Name: non_concurrency_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_pk PRIMARY KEY (priority_line_id, non_priority_line_id);


--
-- TOC entry 3272 (class 2606 OID 84733)
-- Name: odt_area_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odt_area
    ADD CONSTRAINT odt_area_pk PRIMARY KEY (id);


--
-- TOC entry 3274 (class 2606 OID 84735)
-- Name: odt_stop_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_pk PRIMARY KEY (odt_area_id, stop_id, start_date);


--
-- TOC entry 3276 (class 2606 OID 84737)
-- Name: physical_mode_fk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY physical_mode
    ADD CONSTRAINT physical_mode_fk PRIMARY KEY (id);


--
-- TOC entry 3280 (class 2606 OID 84739)
-- Name: poi_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3284 (class 2606 OID 84741)
-- Name: poi_adress_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY poi_adress_datasource
    ADD CONSTRAINT poi_adress_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3282 (class 2606 OID 84743)
-- Name: poi_adress_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY poi_adress
    ADD CONSTRAINT poi_adress_pk PRIMARY KEY (id);


--
-- TOC entry 3278 (class 2606 OID 84745)
-- Name: poi_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY poi
    ADD CONSTRAINT poi_pk PRIMARY KEY (id);


--
-- TOC entry 3286 (class 2606 OID 84747)
-- Name: poi_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY poi_type
    ADD CONSTRAINT poi_type_pk PRIMARY KEY (id);


--
-- TOC entry 3288 (class 2606 OID 84749)
-- Name: printing_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY printing
    ADD CONSTRAINT printing_pk PRIMARY KEY (id);


--
-- TOC entry 3292 (class 2606 OID 84751)
-- Name: route_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3290 (class 2606 OID 84753)
-- Name: route_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_id_pk PRIMARY KEY (id);


--
-- TOC entry 3328 (class 2606 OID 85149)
-- Name: route_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3294 (class 2606 OID 84755)
-- Name: route_section_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_pk PRIMARY KEY (id);


--
-- TOC entry 3296 (class 2606 OID 84757)
-- Name: route_stop_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_pk PRIMARY KEY (id);


--
-- TOC entry 3304 (class 2606 OID 84761)
-- Name: stop_area_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3302 (class 2606 OID 84763)
-- Name: stop_area_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop_area
    ADD CONSTRAINT stop_area_pk PRIMARY KEY (id);


--
-- TOC entry 3306 (class 2606 OID 84765)
-- Name: stop_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3308 (class 2606 OID 84767)
-- Name: stop_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop_history
    ADD CONSTRAINT stop_history_pk PRIMARY KEY (id);


--
-- TOC entry 3300 (class 2606 OID 84769)
-- Name: stop_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_pk PRIMARY KEY (id);


--
-- TOC entry 3310 (class 2606 OID 84771)
-- Name: stop_time_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_pk PRIMARY KEY (id);


--
-- TOC entry 3314 (class 2606 OID 84773)
-- Name: transfer_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3330 (class 2606 OID 85167)
-- Name: transfer_not_exported_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_pk PRIMARY KEY (id);


--
-- TOC entry 3312 (class 2606 OID 84775)
-- Name: transfer_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_pk PRIMARY KEY (id);




--
-- TOC entry 3318 (class 2606 OID 84779)
-- Name: trip_calendar_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trip_calendar
    ADD CONSTRAINT trip_calendar_pk PRIMARY KEY (id);


--
-- TOC entry 3322 (class 2606 OID 84781)
-- Name: trip_datasource_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_pk PRIMARY KEY (id);


--
-- TOC entry 3316 (class 2606 OID 84783)
-- Name: trip_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_pk PRIMARY KEY (id);


--
-- TOC entry 3298 (class 2606 OID 84759)
-- Name: waypoint_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY waypoint
    ADD CONSTRAINT waypoint_pk PRIMARY KEY (id);


--
-- TOC entry 3331 (class 2606 OID 84784)
-- Name: alias_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3332 (class 2606 OID 84789)
-- Name: calendar_datasource_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3333 (class 2606 OID 84794)
-- Name: calendar_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_datasource
    ADD CONSTRAINT calendar_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3334 (class 2606 OID 84799)
-- Name: calendar_element_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3335 (class 2606 OID 84804)
-- Name: calendar_element_included_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_element
    ADD CONSTRAINT calendar_element_included_calendar_id_fk FOREIGN KEY (included_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3336 (class 2606 OID 84809)
-- Name: calendar_link_day_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_day_calendar_id_fk FOREIGN KEY (day_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3337 (class 2606 OID 84814)
-- Name: calendar_link_period_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_period_calendar_id_fk FOREIGN KEY (period_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3338 (class 2606 OID 84819)
-- Name: calendar_link_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY calendar_link
    ADD CONSTRAINT calendar_link_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3339 (class 2606 OID 84824)
-- Name: change_cause_link_change_cause_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_change_cause_id_fk FOREIGN KEY (change_cause_id) REFERENCES change_cause(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3340 (class 2606 OID 84829)
-- Name: change_cause_link_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY change_cause_link
    ADD CONSTRAINT change_cause_link_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3341 (class 2606 OID 84834)
-- Name: city_main_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_main_stop_area_id_fk FOREIGN KEY (main_stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3342 (class 2606 OID 84839)
-- Name: datasource_id_agency_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY datasource
    ADD CONSTRAINT datasource_id_agency_fk FOREIGN KEY (agency_id) REFERENCES agency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3391 (class 2606 OID 84844)
-- Name: grid_calendar_grid_mask_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_calendar
    ADD CONSTRAINT grid_calendar_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3343 (class 2606 OID 84849)
-- Name: grid_calendar_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_calendar
    ADD CONSTRAINT grid_calendar_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3344 (class 2606 OID 84854)
-- Name: grid_link_calendar_mask_type_grid_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_grid_calendar_id_fk FOREIGN KEY (grid_calendar_id) REFERENCES grid_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3345 (class 2606 OID 84859)
-- Name: grid_link_calendar_mask_type_grid_mask_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY grid_link_calendar_mask_type
    ADD CONSTRAINT grid_link_calendar_mask_type_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3347 (class 2606 OID 84864)
-- Name: line_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3348 (class 2606 OID 84869)
-- Name: line_datasource_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_datasource
    ADD CONSTRAINT line_datasource_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3346 (class 2606 OID 84874)
-- Name: line_physical_mode_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_physical_mode_fk FOREIGN KEY (physical_mode_id) REFERENCES physical_mode(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3350 (class 2606 OID 84879)
-- Name: line_version_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3351 (class 2606 OID 84884)
-- Name: line_version_datasource_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_datasource
    ADD CONSTRAINT line_version_datasource_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3349 (class 2606 OID 84889)
-- Name: line_version_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version
    ADD CONSTRAINT line_version_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3395 (class 2606 OID 85132)
-- Name: line_version_not_exported_export_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3396 (class 2606 OID 85137)
-- Name: line_version_not_exported_line_version_id_pk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY line_version_not_exported
    ADD CONSTRAINT line_version_not_exported_line_version_id_pk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3352 (class 2606 OID 84894)
-- Name: non_concurrency_non_priority_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_non_priority_line_id_fk FOREIGN KEY (non_priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3353 (class 2606 OID 84899)
-- Name: non_concurrency_priority_line_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY non_concurrency
    ADD CONSTRAINT non_concurrency_priority_line_id_fk FOREIGN KEY (priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3354 (class 2606 OID 84904)
-- Name: odt_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_area
    ADD CONSTRAINT odt_area_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3355 (class 2606 OID 84909)
-- Name: odt_stop_odt_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_odt_area_id_fk FOREIGN KEY (odt_area_id) REFERENCES odt_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3356 (class 2606 OID 84914)
-- Name: odt_stop_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY odt_stop
    ADD CONSTRAINT odt_stop_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3358 (class 2606 OID 84919)
-- Name: poi_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3359 (class 2606 OID 84924)
-- Name: poi_datasource_poi_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_datasource
    ADD CONSTRAINT poi_datasource_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3361 (class 2606 OID 84929)
-- Name: poi_adress_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_adress_datasource
    ADD CONSTRAINT poi_adress_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3362 (class 2606 OID 84934)
-- Name: poi_adress_datasource_poi_adress_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_adress_datasource
    ADD CONSTRAINT poi_adress_datasource_poi_adress_id_fk FOREIGN KEY (poi_adress_id) REFERENCES poi_adress(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3360 (class 2606 OID 84939)
-- Name: poi_adress_poi_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi_adress
    ADD CONSTRAINT poi_adress_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3357 (class 2606 OID 84944)
-- Name: poi_poi_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY poi
    ADD CONSTRAINT poi_poi_type_id_fk FOREIGN KEY (poi_type_id) REFERENCES poi_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3363 (class 2606 OID 84949)
-- Name: printing_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY printing
    ADD CONSTRAINT printing_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3364 (class 2606 OID 84954)
-- Name: route_comment_id; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_comment_id FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3366 (class 2606 OID 84959)
-- Name: route_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3367 (class 2606 OID 84964)
-- Name: route_datasource_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_datasource
    ADD CONSTRAINT route_datasource_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3365 (class 2606 OID 84969)
-- Name: route_line_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3397 (class 2606 OID 85150)
-- Name: route_not_exported_export_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3398 (class 2606 OID 85155)
-- Name: route_not_exported_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_not_exported
    ADD CONSTRAINT route_not_exported_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3368 (class 2606 OID 84974)
-- Name: route_section_end_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3369 (class 2606 OID 84979)
-- Name: route_section_start_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_section
    ADD CONSTRAINT route_section_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3370 (class 2606 OID 84984)
-- Name: route_stop_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3371 (class 2606 OID 84989)
-- Name: route_stop_route_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_route_section_id_fk FOREIGN KEY (route_section_id) REFERENCES route_section(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3372 (class 2606 OID 84994)
-- Name: route_stop_waypoint_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY route_stop
    ADD CONSTRAINT route_stop_waypoint_id_fk FOREIGN KEY (waypoint_id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3376 (class 2606 OID 84999)
-- Name: stop_area_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area
    ADD CONSTRAINT stop_area_city_id_fk FOREIGN KEY (city_id) REFERENCES city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3377 (class 2606 OID 85004)
-- Name: stop_area_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3378 (class 2606 OID 85009)
-- Name: stop_area_datasource_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_area_datasource
    ADD CONSTRAINT stop_area_datasource_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3379 (class 2606 OID 85014)
-- Name: stop_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3380 (class 2606 OID 85019)
-- Name: stop_datasource_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_datasource
    ADD CONSTRAINT stop_datasource_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3381 (class 2606 OID 85024)
-- Name: stop_history_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_history
    ADD CONSTRAINT stop_history_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3373 (class 2606 OID 85029)
-- Name: stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3374 (class 2606 OID 85034)
-- Name: stop_master_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_master_stop_id_fk FOREIGN KEY (master_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3375 (class 2606 OID 85039)
-- Name: stop_stop_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop
    ADD CONSTRAINT stop_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3382 (class 2606 OID 85044)
-- Name: stop_time_route_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_route_stop_id_fk FOREIGN KEY (route_stop_id) REFERENCES route_stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3383 (class 2606 OID 85049)
-- Name: stop_time_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY stop_time
    ADD CONSTRAINT stop_time_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3386 (class 2606 OID 85054)
-- Name: transfer_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3387 (class 2606 OID 85059)
-- Name: transfer_datasource_transfer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_datasource
    ADD CONSTRAINT transfer_datasource_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3384 (class 2606 OID 85064)
-- Name: transfer_end_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3400 (class 2606 OID 85173)
-- Name: transfer_not_exported_exporte_destination_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_exporte_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3399 (class 2606 OID 85168)
-- Name: transfer_not_exported_transfer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer_not_exported
    ADD CONSTRAINT transfer_not_exported_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3385 (class 2606 OID 85069)
-- Name: transfer_start_stop_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY transfer
    ADD CONSTRAINT transfer_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;




--
-- TOC entry 3388 (class 2606 OID 85079)
-- Name: trip_comment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_comment_id_fk FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3393 (class 2606 OID 85084)
-- Name: trip_datasource_datasource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3394 (class 2606 OID 85089)
-- Name: trip_datasource_trip_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip_datasource
    ADD CONSTRAINT trip_datasource_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3389 (class 2606 OID 85094)
-- Name: trip_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3390 (class 2606 OID 85099)
-- Name: trip_trip_calendar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: endiv_owner
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_trip_calendar_id_fk FOREIGN KEY (trip_calendar_id) REFERENCES trip_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


-- Index creation
CREATE INDEX ON route_datasource (code);
CREATE INDEX ON route_datasource (route_id);
CREATE INDEX ON trip_datasource (code);
CREATE INDEX ON trip_datasource (trip_id);
CREATE INDEX ON stop_datasource (code);
CREATE INDEX ON stop_datasource (stop_id);
CREATE INDEX ON route (line_version_id);
CREATE INDEX ON trip (route_id);
CREATE INDEX ON route_stop (route_id);
CREATE INDEX ON route_stop (waypoint_id);
CREATE INDEX ON stop_time (route_stop_id);
CREATE INDEX ON stop_time (trip_id);
CREATE INDEX ON calendar_link (trip_id);
CREATE INDEX ON calendar_link (period_calendar_id);
CREATE INDEX ON calendar_link (day_calendar_id);
CREATE INDEX ON calendar_element (calendar_id);
CREATE INDEX ON poi (poi_type_id);
CREATE INDEX ON poi_adress (poi_id);


-- Rights creation
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;

REVOKE ALL ON SCHEMA public FROM endiv_owner;
REVOKE ALL ON SCHEMA public FROM endiv_reader;
GRANT USAGE ON SCHEMA public TO endiv_reader;
GRANT USAGE ON SCHEMA public TO endiv_owner;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
GRANT ALL ON ALL TABLES IN SCHEMA public TO PUBLIC;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;

GRANT ALL ON ALL TABLES IN SCHEMA public TO endiv_owner;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO endiv_owner;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO endiv_reader;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO endiv_reader;

-- Doesn't work, TODO: find a way to deny SELECT function to user endiv_reader
-- (stored_procedures)
ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM endiv_reader;
ALTER DEFAULT PRIVILEGES GRANT ALL ON FUNCTIONS TO endiv_owner;

-- Completed on 2014-12-19 12:31:35

--
-- PostgreSQL database dump complete
--
