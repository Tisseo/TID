--
-- Creation de la structure de tables ENDIV
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE SCHEMA pgis;
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA pgis;



-- wrapper de fichiers txt type csv utilisé pour les imports gtfs
CREATE EXTENSION IF NOT EXISTS file_fdw;
COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper which can be used to access data files in the (server)file system';
CREATE SERVER file_fdw_server FOREIGN DATA WRAPPER file_fdw;


SET default_tablespace = '';
SET default_with_oids = false;
-- chemins par defaut
DO $$BEGIN
   execute 'alter database ' || current_database() || ' set search_path = public, pg_catalog, pgis';
END;$$;

-- Creation des tables, cles primaires et indexes

CREATE TYPE address AS (
	address character varying,
	the_geom character varying,
	is_entrance boolean
);

CREATE TABLE agency (
    id serial,
    name character varying(30),
    url character varying(100),
    timezone character varying(30),
    lang character varying(3),
    phone character varying(20)
);
COMMENT ON TABLE agency IS 'Reseau de transport en commun. Contient egalement le fuseau horaire et la langue.';
ALTER TABLE ONLY agency ADD CONSTRAINT agency_pk PRIMARY KEY (id);

CREATE TABLE alias (
    id serial,
    stop_area_id integer,
    name character varying(255)
);
COMMENT ON TABLE alias IS 'Alias des zones d''arrets.';
ALTER TABLE ONLY alias ADD CONSTRAINT alias_pk PRIMARY KEY (id);

CREATE TABLE calendar (
    id serial,
    name character varying(50) NOT NULL,
    calendar_type integer NOT NULL
);
COMMENT ON TABLE calendar IS 'Le calendrier d''application des services en production. Il est lui-meme compose de calendar_element.';
ALTER TABLE ONLY calendar ADD CONSTRAINT calendar_pk PRIMARY KEY (id);

CREATE TABLE calendar_datasource (
    id serial,
    calendar_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE calendar_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY calendar_datasource ADD CONSTRAINT calendar_datasource_pk PRIMARY KEY (id);

CREATE TABLE calendar_element (
    id serial,
    calendar_id integer NOT NULL,
    start_date date,
    end_date date,
    positive character varying(1) NOT NULL,
    "interval" integer,
    included_calendar_id integer
);
COMMENT ON TABLE calendar_element IS 'Element composant le calendrier. Il a comme champs les bornes, l''agencement avec d''autres calendar-element, un intervalle de repetition en cas de calendrier recurrent (lundi), et peut inclure un calendrier.';
COMMENT ON COLUMN calendar_element.positive IS 'agencement des calendar_element d''un meme calendrier : ajout, soustraction, intersection avec les precedents';
COMMENT ON COLUMN calendar_element."interval" IS 'intervalle de repetition en cas de calendrier recurrent (lundi)';
COMMENT ON COLUMN calendar_element.included_calendar_id IS 'id du calendrier inclus';
ALTER TABLE ONLY calendar_element ADD CONSTRAINT calendar_element_pk PRIMARY KEY (id);
CREATE INDEX calendar_element_calendar_id_idx ON calendar_element USING btree (calendar_id);

CREATE TABLE calendar_link (
    id serial,
    trip_id integer NOT NULL,
    day_calendar_id integer NOT NULL,
    period_calendar_id integer NOT NULL
);
COMMENT ON TABLE calendar_link IS 'Lien entre les calendriers et les services (trip) de production auxquels il s''applique.';
ALTER TABLE ONLY calendar_link ADD CONSTRAINT calendar_link_pk PRIMARY KEY (id);
CREATE INDEX calendar_link_day_calendar_id_idx ON calendar_link USING btree (day_calendar_id);
CREATE INDEX calendar_link_period_calendar_id_idx ON calendar_link USING btree (period_calendar_id);
CREATE INDEX calendar_link_trip_id_idx ON calendar_link USING btree (trip_id);

CREATE TABLE change_cause (
    id serial,
    description character varying(255)
);
COMMENT ON TABLE change_cause IS 'Motif de creation d''une nouvelle line_version.';
ALTER TABLE ONLY change_cause ADD CONSTRAINT change_cause_pk PRIMARY KEY (id);

CREATE TABLE change_cause_link (
    id serial,
    change_cause_id integer,
    line_version_id integer
);
COMMENT ON TABLE change_cause_link IS 'Lien entre les motifs de nouvelle line_version et la line_version.';
ALTER TABLE ONLY change_cause_link ADD CONSTRAINT change_cause_link_pk PRIMARY KEY (id);

CREATE TABLE city (
    id serial,
    insee character varying(5) NOT NULL,
    name character varying(255) NOT NULL,
    main_stop_area_id integer,
    the_geom geometry(Polygon,3943)
 );
COMMENT ON TABLE city IS 'Commune.';
ALTER TABLE ONLY city ADD CONSTRAINT city_pk PRIMARY KEY (id);

CREATE TABLE comment (
    id serial,
    label character varying(5),
    comment_text character varying(255)
);
COMMENT ON TABLE comment IS 'Note sur un itineraire (route) ou un service (trip). Signale une particularite sur les fiches horaire.';
COMMENT ON COLUMN comment.label IS 'Lettre servant a signer le commentaire.';
COMMENT ON COLUMN comment.comment_text IS 'Description textuelle du commentaire.';
ALTER TABLE ONLY comment ADD CONSTRAINT comment_pk PRIMARY KEY (id);

CREATE TABLE datasource (
    id serial,
    name character varying(30) NOT NULL,
    agency_id integer NOT NULL
);
COMMENT ON TABLE datasource IS 'Referentiel fournisseur de donnees. Les lignes saisies manuellement ont pour referentiel le ''Service donnes''.';
ALTER TABLE ONLY datasource ADD CONSTRAINT datasource_pk PRIMARY KEY (id);

CREATE TABLE exception_type (
    id serial,
    label character varying(5),
    exception_text character varying(255),
    grid_calendar_pattern character varying(7),
    trip_calendar_pattern character varying(7)
);
COMMENT ON TABLE exception_type IS 'Base de connaissance des type de commentaires.';
COMMENT ON COLUMN exception_type.label IS 'Lettre servant a signer le commentaire.';
COMMENT ON COLUMN exception_type.exception_text IS 'Description textuelle du commentaire.';
COMMENT ON COLUMN exception_type.grid_calendar_pattern IS 'Circulation LMMJVSD de la grille horaire cible.';
COMMENT ON COLUMN exception_type.trip_calendar_pattern IS 'Circulation LMMJVSD du service cible.';
ALTER TABLE ONLY exception_type ADD CONSTRAINT exception_type_pk PRIMARY KEY (id);

CREATE TABLE export_destination (
    id serial,
    nom character varying(255),
    url text
);
ALTER TABLE ONLY export_destination ADD CONSTRAINT export_destination_pk PRIMARY KEY (id);

CREATE TABLE export_perso (
    table_name character varying(30) NOT NULL
);
ALTER TABLE ONLY export_perso ADD CONSTRAINT export_perso_pk PRIMARY KEY (table_name);

CREATE TABLE export_prod (
    table_name character varying(30) NOT NULL
);
ALTER TABLE ONLY export_prod ADD CONSTRAINT export_prod_pk PRIMARY KEY (table_name);

CREATE TABLE grid_calendar (
    id serial,
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
COMMENT ON TABLE grid_calendar IS 'Grille horaire d''une fiche horaire. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';
ALTER TABLE ONLY grid_calendar ADD CONSTRAINT grid_calendar_pk PRIMARY KEY (id);

CREATE TABLE grid_link_calendar_mask_type (
    id serial,
    grid_calendar_id integer NOT NULL,
    grid_mask_type_id integer NOT NULL,
    active boolean NOT NULL
);
COMMENT ON TABLE grid_link_calendar_mask_type IS 'Lien entre les calendriers Hastus fiche horaire et les grilles horaires de la fiche. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';
ALTER TABLE ONLY grid_link_calendar_mask_type ADD CONSTRAINT grid_link_calendar_mask_type_pk PRIMARY KEY (id);

CREATE TABLE grid_mask_type (
    id serial,
    calendar_type character varying(50),
    calendar_period character varying(100)
);
COMMENT ON TABLE grid_mask_type IS 'Type des calendriers envoyes par Hastus pour les fiches horaires.Table remplie par l''import Hastus FICHOR pour les lignes exploitees par Tisseo.';
COMMENT ON COLUMN grid_mask_type.calendar_type IS 'Type du calendrier. Semaine correspond à LaV si un type Samedi existe sur l''offre et à LaS sinon. Dimanche regroupe egalement les jours feries.';
COMMENT ON COLUMN grid_mask_type.calendar_period IS 'Periode d''application du calendrier. BASE correspond a la periode hors vacances si une periode vacance existe sur cette offre et a la periode hiver sinon.';
ALTER TABLE ONLY grid_mask_type ADD CONSTRAINT grid_mask_type_pk PRIMARY KEY (id);

CREATE TABLE line (
    id serial,
    number character varying(10) NOT NULL,
    physical_mode_id integer NOT NULL,
    priority integer NOT NULL
);
COMMENT ON TABLE line IS 'Ligne commerciale de TC.';
ALTER TABLE ONLY line ADD CONSTRAINT line_pk PRIMARY KEY (id);

CREATE TABLE line_datasource (
    id serial,
    line_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE line_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY line_datasource ADD CONSTRAINT line_datasource_pk PRIMARY KEY (id);

CREATE TABLE line_version (
    id serial,
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
COMMENT ON TABLE line_version IS 'Offre d''une ligne.';
COMMENT ON COLUMN line_version.start_date IS 'Date de debut d''offre.';
COMMENT ON COLUMN line_version.end_date IS 'Date effective de fin d''offre, non reneignee a la creation.';
COMMENT ON COLUMN line_version.planned_end_date IS 'Date de fin previsionnelle d''offre.';
COMMENT ON COLUMN line_version.child_line_id IS 'Ligne rattachee (ligne de soiree)';
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_pk PRIMARY KEY (id);

CREATE TABLE line_version_datasource (
    id serial,
    line_version_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE line_version_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY line_version_datasource ADD CONSTRAINT line_version_datasource_pk PRIMARY KEY (id);

CREATE TABLE line_version_not_exported (
    id serial,
    line_version_id integer,
    export_destination_id integer
);
COMMENT ON TABLE line_version_not_exported IS 'Line_version qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';
ALTER TABLE ONLY line_version_not_exported ADD CONSTRAINT line_version_not_exported_pk PRIMARY KEY (id);

CREATE TABLE log (
    id serial,
    datetime timestamp without time zone NOT NULL,
    "table" character varying(30) NOT NULL,
    action character varying(20) NOT NULL,
    previous_data text,
    inserted_data text,
    "user" character varying(30) NOT NULL
);
COMMENT ON TABLE log IS 'Trace de toutes les operations sur la base.';
ALTER TABLE ONLY log ADD CONSTRAINT log_pk PRIMARY KEY (id);

CREATE TABLE non_concurrency (
    priority_line_id integer NOT NULL,
    non_priority_line_id integer NOT NULL,
    "time" integer NOT NULL
);
COMMENT ON TABLE non_concurrency IS 'Table des non concurrences, une ligne est prioritaire sur une autre pour un delta de temps.';
ALTER TABLE ONLY non_concurrency ADD CONSTRAINT non_concurrency_pk PRIMARY KEY (priority_line_id, non_priority_line_id);

CREATE TABLE odt_area (
    id serial,
    name character varying(30) NOT NULL,
    comment text
);
COMMENT ON TABLE odt_area IS 'Zone d''arret TAD.';
ALTER TABLE ONLY odt_area ADD CONSTRAINT odt_area_pk PRIMARY KEY (id);

CREATE TABLE odt_stop (
    odt_area_id integer NOT NULL,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    pickup boolean NOT NULL,
    drop_off boolean NOT NULL
);
COMMENT ON TABLE odt_stop IS 'Lien entre un arret et une zone d''arret pour un intervalle de temps.';
ALTER TABLE ONLY odt_stop ADD CONSTRAINT odt_stop_pk PRIMARY KEY (odt_area_id, stop_id, start_date);

CREATE TABLE physical_mode (
    id serial,
    name character varying(30) NOT NULL,
    type character varying(30) NOT NULL
);
COMMENT ON TABLE physical_mode IS 'Mode de transport.';
ALTER TABLE ONLY physical_mode ADD CONSTRAINT physical_mode_fk PRIMARY KEY (id);

CREATE TABLE poi (
    id serial,
    name character varying(255) NOT NULL,
    city_id integer NOT NULL,
    poi_type_id integer NOT NULL,
    priority integer NOT NULL
);
COMMENT ON TABLE poi IS 'Point d''interet. ';
COMMENT ON COLUMN poi.city_id IS 'Commune du POI.';
COMMENT ON COLUMN poi.poi_type_id IS 'Categorie de POI.';
COMMENT ON COLUMN poi.priority IS 'Importance du POI. 1 = prioritaire, 5 = peu important.';
ALTER TABLE ONLY poi ADD CONSTRAINT poi_pk PRIMARY KEY (id);
CREATE INDEX poi_poi_type_id_idx ON poi USING btree (poi_type_id);

CREATE TABLE poi_address (
    id serial,
    poi_id integer NOT NULL,
    address text,
    is_entrance boolean NOT NULL,
    the_geom geometry(Point,3943) NOT NULL
);
COMMENT ON TABLE poi_address IS 'Localisation du POI ou de son entree.';
COMMENT ON COLUMN poi_address.address IS 'Adresse postale de la localisation du POI.';
COMMENT ON COLUMN poi_address.is_entrance IS 'Indique sil la localisation est une entree du POI ou le barycentre du POI.';
ALTER TABLE ONLY poi_address ADD CONSTRAINT poi_address_pk PRIMARY KEY (id);
CREATE INDEX poi_address_poi_id_idx ON poi_address USING btree (poi_id);

CREATE TABLE poi_address_datasource (
    id serial,
    poi_address_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE poi_address_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY poi_address_datasource ADD CONSTRAINT poi_address_datasource_pk PRIMARY KEY (id);


CREATE TABLE poi_datasource (
    id serial,
    poi_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE poi_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY poi_datasource ADD CONSTRAINT poi_datasource_pk PRIMARY KEY (id);

CREATE TABLE poi_type (
    id serial,
    name character varying(50) NOT NULL
);
ALTER TABLE ONLY poi_type ADD CONSTRAINT poi_type_pk PRIMARY KEY (id);

CREATE TABLE printing (
    id serial,
    quantity integer,
    date date,
    line_version_id integer,
    comment text
);
COMMENT ON TABLE printing IS 'Quatite de fiche horaire d''une offre imprimees. Aide a la gestion des document IV.';
COMMENT ON COLUMN printing.comment IS 'Raison du tirage : initial, reassort ou correction.';
ALTER TABLE ONLY printing ADD CONSTRAINT printing_pk PRIMARY KEY (id);

CREATE TABLE route (
    id serial,
    line_version_id integer NOT NULL,
    way character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    direction character varying(255) NOT NULL,
    comment_id integer
);
COMMENT ON TABLE route IS 'Itineraire d''une offre. ';
COMMENT ON COLUMN route.way IS 'Aller ou retour.';
COMMENT ON COLUMN route.name IS 'Nom du parcours type (Hastus ou Tigre).';
COMMENT ON COLUMN route.direction IS 'Titre de la direction, a terme, viendra de l''application girouette.';
ALTER TABLE ONLY route ADD CONSTRAINT route_id_pk PRIMARY KEY (id);
CREATE INDEX route_line_version_id_idx ON route USING btree (line_version_id);

CREATE TABLE route_datasource (
    id serial,
    route_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE route_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY route_datasource ADD CONSTRAINT route_datasource_pk PRIMARY KEY (id);
CREATE INDEX route_datasource_code_idx ON route_datasource USING btree (code);
CREATE INDEX route_datasource_route_id_idx ON route_datasource USING btree (route_id);

CREATE TABLE route_not_exported (
    id serial,
    route_id integer,
    export_destination_id integer
);
COMMENT ON TABLE route_not_exported IS 'Routes qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';
ALTER TABLE ONLY route_not_exported ADD CONSTRAINT route_not_exported_pk PRIMARY KEY (id);

CREATE TABLE route_section (
    id serial,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    the_geom geometry(LineString,3943) NOT NULL
);
COMMENT ON TABLE route_section IS 'Troncon inter-arrets provenant de Tigre. Les dates permettent de gerer des changement de parcours entre 2 arrets. Un troncon est unique pour une geometrie et ses arrets depart-arrivee.';
COMMENT ON COLUMN route_section.start_date IS 'Date de la creation de ce troncon. Un nouveau troncon est cree si arret debut ou arret fin ou geom est nouvelle.';
COMMENT ON COLUMN route_section.end_date IS 'Date de fin d''utilisation du troncon. Lorsqu''un nouveau troncon (meme debut, meme fin mais geom differente) est cree, le precedentest cloture.';
COMMENT ON COLUMN route_section.the_geom IS 'Geometrie de Tigre.';
ALTER TABLE ONLY route_section ADD CONSTRAINT route_section_pk PRIMARY KEY (id);

CREATE TABLE route_stop (
    id serial,
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
COMMENT ON TABLE route_stop IS 'Troncon d''un itineraire, qui passe par un waypoint selon un rang.';
COMMENT ON COLUMN route_stop.route_id IS 'Itineraire du troncon.';
COMMENT ON COLUMN route_stop.waypoint_id IS 'Point de passage du debut du troncon. Peut renvoyer vers un arret ou une zone TAD.';
COMMENT ON COLUMN route_stop.rank IS 'Ordre dans l''itineraire. Commence a 1.';
COMMENT ON COLUMN route_stop.scheduled_stop IS 'Indique s''il s''agit d''un waypoint qui comporte des horaires.';
COMMENT ON COLUMN route_stop.internal_service IS 'Dans le cas d''une zone TAD, idique si la desserte interne de la zone est autorisee.';
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_pk PRIMARY KEY (id);
CREATE INDEX route_stop_route_id_idx ON route_stop USING btree (route_id);
CREATE INDEX route_stop_waypoint_id_idx ON route_stop USING btree (waypoint_id);

CREATE TABLE stop_area (
    id serial,
    short_name character varying(255) NOT NULL,
    long_name character varying(255),
    city_id integer NOT NULL,
    transfer_duration integer NOT NULL,
    the_geom geometry(Point,3943)
);
COMMENT ON TABLE stop_area IS 'Zone d''arret comportant un ou plusieurs arrets.';
COMMENT ON COLUMN stop_area.short_name IS 'Nom identique aux noms des arrets le composant.';
COMMENT ON COLUMN stop_area.long_name IS 'Par defaut, le long_name est identique aux noms des arrets le composant, il peut etre modifie pour developper les abbreviations du nom court.';
COMMENT ON COLUMN stop_area.transfer_duration IS 'Temps en secondes de transfert entre deux arret de cette zone d''arrets.';
ALTER TABLE ONLY stop_area ADD CONSTRAINT stop_area_pk PRIMARY KEY (id);

CREATE TABLE stop (
    id serial,
    stop_area_id integer NOT NULL,
    master_stop_id integer
);
COMMENT ON TABLE stop IS 'Arret de bus ou de TAD, quai de tram ou de metro.';
ALTER TABLE ONLY stop ADD CONSTRAINT stop_pk PRIMARY KEY (id);

CREATE TABLE stop_area_datasource (
    id serial,
    stop_area_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE stop_area_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY stop_area_datasource ADD CONSTRAINT stop_area_datasource_pk PRIMARY KEY (id);

CREATE TABLE stop_datasource (
    id serial,
    stop_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE stop_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY stop_datasource ADD CONSTRAINT stop_datasource_pk PRIMARY KEY (id);
CREATE INDEX stop_datasource_code_idx ON stop_datasource USING btree (code);
CREATE INDEX stop_datasource_stop_id_idx ON stop_datasource USING btree (stop_id);

CREATE TABLE stop_history (
    id serial,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    short_name character varying(50) NOT NULL,
    long_name character varying(255),
    the_geom geometry(Point,3943) NOT NULL,
    accessibility boolean
);
ALTER TABLE public.stop_history OWNER TO endiv_owner;
COMMENT ON TABLE stop_history IS 'Proprietes d''un arret. Un arret n''a qu''un historique dans le temps. Si une caracteristique cahnge, l''historique precedent est cloture et un nouveau est cree.';
COMMENT ON COLUMN stop_history.short_name IS 'Nom de l''arret dans le referentiel Hastus. Pas de modification possible.';
COMMENT ON COLUMN stop_history.long_name IS 'Champ inutile pour le moment. Laisser vide.';
COMMENT ON COLUMN stop_history.accessibility IS 'Accessibilite de l''arret pour les UFR (fauteuil roulant) selon les releves du service accessibilite.';
ALTER TABLE ONLY stop_history ADD CONSTRAINT stop_history_pk PRIMARY KEY (id);

CREATE TABLE stop_time (
    id serial,
    route_stop_id integer NOT NULL,
    trip_id integer NOT NULL,
    arrival_time integer,
    departure_time integer
);
COMMENT ON TABLE stop_time IS 'Horaire d''un troncon d''itineraire.';
COMMENT ON COLUMN stop_time.arrival_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';
COMMENT ON COLUMN stop_time.departure_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';
ALTER TABLE ONLY stop_time ADD CONSTRAINT stop_time_pk PRIMARY KEY (id);
CREATE INDEX stop_time_trip_id_idx ON stop_time USING btree (trip_id);
CREATE INDEX stop_time_route_stop_id_idx ON stop_time USING btree (route_stop_id);

CREATE TABLE transfer (
    id serial,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    duration integer NOT NULL,
    distance integer,
    the_geom geometry(Point,3943),
    accessibility boolean,
    description text
);
COMMENT ON TABLE transfer IS 'Correspondance entre deux arrets.';
COMMENT ON COLUMN transfer.duration IS 'Temps de transfert en secondes.';
COMMENT ON COLUMN transfer.distance IS 'Distance en metres de la correspondance.';
COMMENT ON COLUMN transfer.the_geom IS 'Trace de la correspondance. Inutilise pour le moment.';
COMMENT ON COLUMN transfer.accessibility IS 'Accessibilite de la correspondance. Inutilise pour le moment.';
ALTER TABLE ONLY transfer ADD CONSTRAINT transfer_pk PRIMARY KEY (id);

CREATE TABLE transfer_datasource (
    id serial,
    transfer_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE transfer_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY transfer_datasource ADD CONSTRAINT transfer_datasource_pk PRIMARY KEY (id);
CREATE TABLE transfer_not_exported (
    id serial,
    transfer_id integer,
    export_destination_id integer
);
COMMENT ON TABLE transfer_not_exported IS 'Correspondances qui ne doivent pas être exportées en production car il y a un travail en cours ou obsolete.';
ALTER TABLE ONLY transfer_not_exported ADD CONSTRAINT transfer_not_exported_pk PRIMARY KEY (id);
CREATE TABLE trip (
    id serial,
    name character varying(20) NOT NULL,
    route_id integer NOT NULL,
    trip_calendar_id integer,
    comment_id integer
);
COMMENT ON TABLE trip IS 'Service d''un itineraire. Fait le lien entre les horaires et les itineraires.';
COMMENT ON COLUMN trip.name IS 'Nom de l''objet. Si vient d''Hastus, identiques a la datasource.';
COMMENT ON COLUMN trip.trip_calendar_id IS 'Lien vers un calendrier de fiche horaire. Null si il s''agit d''un service de prod non present dans les fiches horaires.';
COMMENT ON COLUMN trip.comment_id IS 'Lien vers les commentaires pour les fiches horaires.';
ALTER TABLE ONLY trip ADD CONSTRAINT trip_pk PRIMARY KEY (id);
CREATE INDEX trip_route_id_idx ON trip USING btree (route_id);

CREATE TABLE trip_calendar (
    id serial,
    grid_mask_type_id integer NOT NULL,
    monday boolean NOT NULL,
    tuesday boolean NOT NULL,
    wednesday boolean NOT NULL,
    thursday boolean NOT NULL,
    friday boolean NOT NULL,
    saturday boolean NOT NULL,
    sunday boolean NOT NULL
);
COMMENT ON TABLE trip_calendar IS 'Description des jours de circulation des services (trips) pour les fiches horaires. Table remplie par l''import Hastus FICHOR pour les lignes exploitees par Tisseo.';
ALTER TABLE ONLY trip_calendar ADD CONSTRAINT trip_calendar_pk PRIMARY KEY (id);

CREATE TABLE trip_datasource (
    id serial,
    trip_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE trip_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
ALTER TABLE ONLY trip_datasource ADD CONSTRAINT trip_datasource_pk PRIMARY KEY (id);
CREATE INDEX trip_datasource_trip_id_idx ON trip_datasource USING btree (trip_id);
CREATE INDEX trip_datasource_code_idx ON trip_datasource USING btree (code);

CREATE TABLE waypoint (
    id serial
);
ALTER TABLE ONLY waypoint ADD CONSTRAINT waypoint_pk PRIMARY KEY (id);


-- Creation des cles etrangeres

ALTER TABLE ONLY route_datasource ADD CONSTRAINT route_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_datasource ADD CONSTRAINT route_datasource_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_area ADD CONSTRAINT stop_area_city_id_fk FOREIGN KEY (city_id) REFERENCES city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_master_stop_id_fk FOREIGN KEY (master_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_area_datasource ADD CONSTRAINT stop_area_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_area_datasource ADD CONSTRAINT stop_area_datasource_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_datasource ADD CONSTRAINT stop_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_datasource ADD CONSTRAINT stop_datasource_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_history ADD CONSTRAINT stop_history_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_time ADD CONSTRAINT stop_time_route_stop_id_fk FOREIGN KEY (route_stop_id) REFERENCES route_stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_time ADD CONSTRAINT stop_time_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route ADD CONSTRAINT route_comment_id FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route ADD CONSTRAINT route_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY printing ADD CONSTRAINT printing_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_datasource ADD CONSTRAINT poi_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_datasource ADD CONSTRAINT poi_datasource_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address_datasource ADD CONSTRAINT poi_address_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address_datasource ADD CONSTRAINT poi_address_datasource_poi_address_id_fk FOREIGN KEY (poi_address_id) REFERENCES poi_address(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address ADD CONSTRAINT poi_address_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_datasource ADD CONSTRAINT trip_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_datasource ADD CONSTRAINT trip_datasource_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_calendar ADD CONSTRAINT grid_calendar_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_comment_id_fk FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_trip_calendar_id_fk FOREIGN KEY (trip_calendar_id) REFERENCES trip_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_not_exported ADD CONSTRAINT transfer_not_exported_exporte_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_not_exported ADD CONSTRAINT transfer_not_exported_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_datasource ADD CONSTRAINT transfer_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_datasource ADD CONSTRAINT transfer_datasource_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer ADD CONSTRAINT transfer_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer ADD CONSTRAINT transfer_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_not_exported ADD CONSTRAINT route_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_not_exported ADD CONSTRAINT route_not_exported_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_section ADD CONSTRAINT route_section_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_section ADD CONSTRAINT route_section_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_route_section_id_fk FOREIGN KEY (route_section_id) REFERENCES route_section(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_waypoint_id_fk FOREIGN KEY (waypoint_id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_stop ADD CONSTRAINT odt_stop_odt_area_id_fk FOREIGN KEY (odt_area_id) REFERENCES odt_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_stop ADD CONSTRAINT odt_stop_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_area ADD CONSTRAINT odt_area_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY non_concurrency ADD CONSTRAINT non_concurrency_non_priority_line_id_fk FOREIGN KEY (non_priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY non_concurrency ADD CONSTRAINT non_concurrency_priority_line_id_fk FOREIGN KEY (priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi ADD CONSTRAINT poi_poi_type_id_fk FOREIGN KEY (poi_type_id) REFERENCES poi_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_not_exported ADD CONSTRAINT line_version_not_exported_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_not_exported ADD CONSTRAINT line_version_not_exported_line_version_id_pk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_datasource ADD CONSTRAINT line_version_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_datasource ADD CONSTRAINT line_version_datasource_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_datasource ADD CONSTRAINT line_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_datasource ADD CONSTRAINT line_datasource_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line ADD CONSTRAINT line_physical_mode_fk FOREIGN KEY (physical_mode_id) REFERENCES physical_mode(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_link_calendar_mask_type ADD CONSTRAINT grid_link_calendar_mask_type_grid_calendar_id_fk FOREIGN KEY (grid_calendar_id) REFERENCES grid_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_link_calendar_mask_type ADD CONSTRAINT grid_link_calendar_mask_type_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_calendar ADD CONSTRAINT grid_calendar_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY datasource ADD CONSTRAINT datasource_id_agency_fk FOREIGN KEY (agency_id) REFERENCES agency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY city ADD CONSTRAINT city_main_stop_area_id_fk FOREIGN KEY (main_stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY change_cause_link ADD CONSTRAINT change_cause_link_change_cause_id_fk FOREIGN KEY (change_cause_id) REFERENCES change_cause(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY change_cause_link ADD CONSTRAINT change_cause_link_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_link ADD CONSTRAINT calendar_link_day_calendar_id_fk FOREIGN KEY (day_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_link ADD CONSTRAINT calendar_link_period_calendar_id_fk FOREIGN KEY (period_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_link ADD CONSTRAINT calendar_link_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_element ADD CONSTRAINT calendar_element_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_element ADD CONSTRAINT calendar_element_included_calendar_id_fk FOREIGN KEY (included_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_datasource ADD CONSTRAINT calendar_datasource_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_datasource ADD CONSTRAINT calendar_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY alias ADD CONSTRAINT alias_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
