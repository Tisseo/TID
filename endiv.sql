--
-- Creation de la structure de tables ENDIV
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--creation des types
CREATE TYPE calendar_type AS ENUM ('jour', 'periode', 'mixte', 'accessibilite', 'brique');
CREATE TYPE line_version_status AS ENUM ('new', 'wip', 'published', 'test');
CREATE TYPE calendar_operator AS ENUM ('+', '-', '&');

-- Creation des tables, cles primaires et indexes
CREATE TABLE accessibility_mode (
    id serial PRIMARY KEY,
    name character varying(30) NOT NULL
);
COMMENT ON TABLE accessibility_mode IS 'Mode d''accessibilite : pieton, UFR, vélos, ...';

CREATE TABLE accessibility_type (
    id serial PRIMARY KEY,
    accessibility_mode_id integer NOT NULL,
    calendar_id integer NOT NULL,
    start_time integer,
    end_time integer,
    is_recursive boolean
);
COMMENT ON TABLE accessibility_type IS 'Mode d''accessibilite : pieton, UFR, vélos, ...';
COMMENT ON COLUMN accessibility_type.start_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59. Explicite l''heure de départ de l''innaccessibilité du calendrier';
COMMENT ON COLUMN accessibility_type.end_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59. Explicite l''heure de fin de l''innaccessibilité du calendrier';
COMMENT ON COLUMN accessibility_type.is_recursive IS 'Si vrai, les heures de departs et fin s''appliquent tous les jours du calendier. Sinon, l''heure de depart s''applique au premier jour du calendrier et l''heure de fin au dernier';

CREATE TABLE agency (
    id serial PRIMARY KEY,
    name character varying(30) NOT NULL,
    url character varying(100),
    timezone character varying(30) NOT NULL,
    lang character varying(3),
    phone character varying(20)
);
COMMENT ON TABLE agency IS 'Reseau de transport en commun. Contient egalement le fuseau horaire et la langue.';

CREATE TABLE alias (
    id serial PRIMARY KEY,
    stop_area_id integer NOT NULL,
    name character varying(255) NOT NULL
);
COMMENT ON TABLE alias IS 'Alias des zones d''arrets.';

CREATE TABLE global_vars (name TEXT PRIMARY KEY, value TEXT);
INSERT INTO global_vars (name, value) VALUES ('maximum_calendar_date', '2020-12-31');
COMMENT ON TABLE global_vars IS 'Definit des variables globales de la base. Notament la date maximum de fin des calendars elements qui evoluera d''un an tous les ans : par un appel de la procedure updatecalendarlimit.';

CREATE TABLE calendar (
    id serial PRIMARY KEY,
    name character varying(50) NOT NULL,
    "calendar_type" calendar_type,
    line_version_id integer,
	computed_start_date date,
	computed_end_date date
);
COMMENT ON TABLE calendar IS 'Le calendrier d''application des services en production. Il est lui-meme compose de calendar_element.';
COMMENT ON COLUMN calendar.computed_start_date IS 'Propriete calculee correspondant a la date de debut d''application du calendrier ';
COMMENT ON COLUMN calendar.computed_end_date IS 'Propriete calculee correspondant a la date de fin d''application du calendrier';
CREATE INDEX calendar_line_version_id_idx ON calendar USING btree (line_version_id);

CREATE TABLE calendar_datasource (
    id serial PRIMARY KEY,
    calendar_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE calendar_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE calendar_element (
    id serial PRIMARY KEY,
    calendar_id integer NOT NULL,
    rank integer NOT NULL,
    start_date date,
    end_date date,
    operator calendar_operator NOT NULL,
    "interval" integer NOT NULL default 1,
    included_calendar_id integer,
    CHECK (start_date <= end_date)
);
COMMENT ON TABLE calendar_element IS 'Element composant le calendrier. Il a comme champs les bornes, l''agencement avec d''autres calendar-element, un intervalle de repetition en cas de calendrier recurrent (lundi), et peut inclure un calendrier.';
COMMENT ON COLUMN calendar_element.operator IS 'agencement des calendar_element d''un meme calendrier : ajout, soustraction, intersection avec les precedents';
COMMENT ON COLUMN calendar_element."interval" IS 'intervalle de repetition en cas de calendrier recurrent (lundi)';
COMMENT ON COLUMN calendar_element.included_calendar_id IS 'id du calendrier inclus';
CREATE INDEX calendar_element_calendar_id_idx ON calendar_element USING btree (calendar_id);

CREATE TABLE city (
    id serial PRIMARY KEY,
    insee character varying(5) NOT NULL,
    postal_code character varying(5),
    name character varying(255) NOT NULL,
    main_stop_area_id integer,
    the_geom geometry(Polygon,3943)
 );
COMMENT ON TABLE city IS 'Commune.';
COMMENT ON COLUMN city.insee IS 'Code Insee de la commune.';
COMMENT ON COLUMN city.main_stop_area_id IS 'Arret principal de la commune, sert de point de départ lors d''un itineraire depuis ou vers la commune.';
CREATE INDEX city_geom_idx ON city USING GIST (the_geom);
CREATE INDEX city_main_stop_area_id_idx ON city USING btree (main_stop_area_id);

CREATE TABLE comment (
    id serial PRIMARY KEY,
    label character varying(5),
    comment_text character varying(255)
);
COMMENT ON TABLE comment IS 'Note sur un itineraire (route) ou un service (trip). Signale une particularite sur les fiches horaire.';
COMMENT ON COLUMN comment.label IS 'Lettre servant a signer le commentaire. Servira de renvoi dans les FH.';
COMMENT ON COLUMN comment.comment_text IS 'Description textuelle du commentaire.';

CREATE TABLE color (
    id serial PRIMARY KEY,
    name character varying(255) NOT NULL,
    html character varying(7) NOT NULL,
    pantone_oc character varying(100),
    hoxis character varying(100),
    cmyk_cyan integer NOT NULL,
    cmyk_magenta integer NOT NULL,
    cmyk_yellow integer NOT NULL,
    cmyk_black integer NOT NULL,
    rgb_red integer NOT NULL,
    rgb_green integer NOT NULL,
    rgb_blue integer NOT NULL
);
COMMENT ON TABLE color IS 'Référentiel des couleurs de lignes.';
COMMENT ON COLUMN color.html IS 'Comprend le caractère # au debut.';

CREATE TABLE datasource (
    id serial PRIMARY KEY,
    name character varying(30) NOT NULL,
    agency_id integer NOT NULL
);
COMMENT ON TABLE datasource IS 'Referentiel fournisseur de donnees. Le fournisseur peut etre automatique ou une saisie manuelle.';

CREATE TABLE exception_type (
    id serial PRIMARY KEY,
    label character varying(5),
    exception_text character varying(255),
    grid_calendar_pattern character varying(7),
    trip_calendar_pattern character varying(7)
);
COMMENT ON TABLE exception_type IS 'Base de connaissance des type de commentaires. Propose une note par défaut pour les exceptions les plus courantes.';
COMMENT ON COLUMN exception_type.label IS 'Lettre servant a signer le commentaire.';
COMMENT ON COLUMN exception_type.exception_text IS 'Description textuelle du commentaire.';
COMMENT ON COLUMN exception_type.grid_calendar_pattern IS 'Circulation LMMJVSD de la grille horaire cible.';
COMMENT ON COLUMN exception_type.trip_calendar_pattern IS 'Circulation LMMJVSD du service cible.';

CREATE TABLE export_destination (
    id serial PRIMARY KEY,
    name character varying(255),
    url text
);
COMMENT ON TABLE export_destination IS 'Referentiel client de tout ou partie de la base. Permettra de filtrer l''export des objets.';

CREATE TABLE grid_calendar (
    id serial PRIMARY KEY,
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
COMMENT ON TABLE grid_calendar IS 'Grille horaire d''une fiche horaire. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';
CREATE INDEX grid_calendar_line_version_id_idx ON grid_calendar USING btree (line_version_id);

CREATE TABLE grid_link_calendar_mask_type (
    id serial PRIMARY KEY,
    grid_calendar_id integer NOT NULL,
    grid_mask_type_id integer NOT NULL,
    active boolean NOT NULL
);
COMMENT ON TABLE grid_link_calendar_mask_type IS 'Lien entre les calendriers type provenant d''un referentiel exploitation et les fiche horaire et les grilles horaires de la fiche. Table remplie par l''IV via interface dediee lors de la creation de la fiche horaire.';
CREATE INDEX grid_link_calendar_mask_type_grid_calendar_id_idx ON grid_link_calendar_mask_type USING btree (grid_calendar_id);
CREATE INDEX grid_link_calendar_mask_type_grid_mask_type_id_idx ON grid_link_calendar_mask_type USING btree (grid_mask_type_id);

CREATE TABLE grid_mask_type (
    id serial PRIMARY KEY,
    calendar_type character varying(50),
    calendar_period character varying(100),
    calendar_code character varying(10),
    included character varying(10),
    scenario character varying(50),
    start_date date,
    end_date date
);
COMMENT ON TABLE grid_mask_type IS 'Type des calendriers envoyes par le referentiel d''exploitation pour les fiches horaires. Table remplie par l''import de donnees du referentiel d''exploitation.';
COMMENT ON COLUMN grid_mask_type.calendar_type IS 'Type du calendrier. Semaine correspond à LaV si un type Samedi existe sur l''offre et à LaS sinon. Dimanche regroupe egalement les jours feries.';
COMMENT ON COLUMN grid_mask_type.calendar_period IS 'Periode d''application du calendrier. BASE correspond a la periode hors vacances si une periode vacance existe sur cette offre et a la periode hiver sinon.';

CREATE TABLE line (
    id serial PRIMARY KEY,
    number character varying(10) NOT NULL,
    physical_mode_id integer NOT NULL,
    priority integer NOT NULL,
    picto_file character varying(80),
    ticketing_code character varying(255),
    publication_date DATE DEFAULT NULL
);
COMMENT ON TABLE line IS 'Ligne commerciale de TC.';
COMMENT ON COLUMN line.number IS 'Numero de la ligne. Alphanumerique. Par exple : T1, A ou L16 sont des numeros.';
COMMENT ON COLUMN line.priority IS 'Priorité de la ligne. Sert notamment a trier les lignes dans les listes de lignes.';

CREATE TABLE line_status (
    id serial PRIMARY KEY,
    line_id integer NOT NULL,
    date_time timestamp without time zone NOT NULL,
    login character varying(255) NOT NULL,
    status integer NOT NULL,
    comment text
);
COMMENT ON TABLE line_status IS 'Table pour l''exploitation, servant à indiquer le statut de la ligne: nouvelles données, en cours de modif, ...';

CREATE TABLE line_datasource (
    id serial PRIMARY KEY,
    line_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE line_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE line_group (
    id serial PRIMARY KEY,
    name character varying(20)
);
COMMENT ON TABLE line_group IS 'Groupe de ligne. Permet d''associer les lignes avec leurs lignes de soirees ou des linges principales avec leurs lignes filles.';

CREATE TABLE line_group_content (
    line_version_id integer not null,
    line_group_id integer not null,
    is_parent boolean
);
COMMENT ON TABLE line_group IS 'Constitution des groupes de ligne.';

CREATE TABLE line_group_gis (
    id serial PRIMARY KEY,
    name character varying(20),
    nb_bus integer not null default 0,
    comment text,
    deprecated boolean not null default false
);
COMMENT ON TABLE line_group_gis IS 'Groupe de ligne SIG. Permet de gerer des regroupements commerciaux de schemas de ligne.';

CREATE TABLE line_group_gis_content (
    line_id integer not null,
    line_group_gis_id integer not null
);
COMMENT ON TABLE line_group IS 'Constitution des groupes de lignes SIG.';

CREATE TABLE line_version (
    id serial PRIMARY KEY,
    line_id integer NOT NULL,
    version integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    planned_end_date date NOT NULL,
    name character varying(255) NOT NULL,
    forward_direction character varying(255) NOT NULL,
    backward_direction character varying(255) NOT NULL,
    bg_color_id integer NOT NULL,
    fg_color_id integer NOT NULL,
    comment text,
    depot_id integer,
    status line_version_status,
    num_audio integer,
    text2speech character varying(255),
    schematic_id integer DEFAULT NULL
);
COMMENT ON TABLE line_version IS 'Offre d''une ligne.';
COMMENT ON COLUMN line_version.start_date IS 'Date de debut d''offre.';
COMMENT ON COLUMN line_version.end_date IS 'Date effective de fin d''offre, non reneignee a la creation.';
COMMENT ON COLUMN line_version.planned_end_date IS 'Date de fin previsionnelle d''offre.';
COMMENT ON COLUMN line_version.status IS 'Statut de l''offre (commencee, nouvelle,...)';
COMMENT ON COLUMN line_version.schematic_id IS 'Identifiant du schematique de l''offre';
COMMENT ON COLUMN line_version.bg_color_id IS 'Cle vers la couleur de background de l''offre.';
COMMENT ON COLUMN line_version.fg_color_id IS 'Cle vers la couleur de texte de l''offre.';
COMMENT ON COLUMN line_version.depot_id IS 'Cle vers le depot d''exploitation de la ligne (depot bus, garage metro ou tram,...).';

CREATE TABLE line_version_datasource (
    id serial PRIMARY KEY,
    line_version_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE line_version_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE line_version_export_destination (
    id serial PRIMARY KEY,
    line_version_id integer,
    export_destination_id integer
);
CREATE INDEX line_version_export_destination_line_version_id_idx ON line_version_export_destination USING btree (line_version_id);

CREATE TABLE log (
    id serial PRIMARY KEY,
    datetime timestamp without time zone NOT NULL,
    table_name character varying(30) NOT NULL,
    action character varying(20) NOT NULL,
    previous_data text,
    inserted_data text,
    user_login character varying(30) NOT NULL
);
COMMENT ON TABLE log IS 'Trace de toutes les operations sur la base.';

CREATE TABLE modification (
    id serial PRIMARY KEY,
    description character varying(255),
    author character varying(255),
    line_version_id integer,
    date date NOT NULL,
    resolved_in integer
);
COMMENT ON TABLE modification IS 'Modification sur une line_version, soit initialisation soit en cours d exploitation.';
COMMENT ON COLUMN modification.date IS 'Date de la prise d effet de la modification.';
COMMENT ON COLUMN modification.resolved_in IS 'Id de line_version ou cette modification a ete prise en compte. Si la modification n a jamais ete prise en compte, id de line_version durant laquelle le changement a ete releve.';
COMMENT ON COLUMN modification.line_version_id IS 'Id de line_version durant laquelle le changement a ete releve.';
CREATE INDEX modification_line_version_id_idx ON modification USING btree (line_version_id);
CREATE INDEX modification_resolved_idx ON modification USING btree (resolved_in);

CREATE TABLE non_concurrency (
    priority_line_id integer NOT NULL,
    non_priority_line_id integer NOT NULL,
    "time" integer NOT NULL,
    PRIMARY KEY (priority_line_id, non_priority_line_id)
);
COMMENT ON TABLE non_concurrency IS 'Table des non concurrences, une ligne est prioritaire sur une autre pour un delta de temps. Une seule regle de non concurrence peut lier 2 lignes.';

CREATE TABLE odt_area (
    id integer PRIMARY KEY,
    name character varying(30) NOT NULL,
    comment text
);
COMMENT ON TABLE odt_area IS 'Zone d''arret TAD.';

CREATE TABLE odt_stop (
    odt_area_id integer NOT NULL,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    pickup boolean NOT NULL,
    drop_off boolean NOT NULL,
    PRIMARY KEY (odt_area_id, stop_id, start_date)
);
COMMENT ON TABLE odt_stop IS 'Lien entre un arret et une zone d''arret pour un intervalle de temps.';

CREATE TABLE physical_mode (
    id serial PRIMARY KEY,
    name character varying(30) NOT NULL,
    type character varying(30) NOT NULL,
    co2_emission numeric DEFAULT 0.0
);
COMMENT ON TABLE physical_mode IS 'Mode de transport.';
COMMENT ON COLUMN physical_mode.type IS 'A etablir dans la liste des modes autorises : Aérien, Maritime/Fluvial, Ferré, Métro, Tram, Funiculaire/Câble, Bus/Car/Trolley';

CREATE TABLE poi (
    id serial PRIMARY KEY,
    name character varying(255) NOT NULL,
    city_id integer NOT NULL,
    poi_type_id integer NOT NULL,
    priority integer NOT NULL,
    on_schema boolean
);
COMMENT ON TABLE poi IS 'Point d''interet. ';
COMMENT ON COLUMN poi.city_id IS 'Commune du POI.';
COMMENT ON COLUMN poi.poi_type_id IS 'Categorie de POI.';
COMMENT ON COLUMN poi.priority IS 'Importance du POI. 1 = prioritaire, 5 = peu important.';
COMMENT ON COLUMN poi.on_schema IS 'Affichage du POI sur les schemas de lignes, provient de Tigre.';
CREATE INDEX poi_poi_type_id_idx ON poi USING btree (poi_type_id);

CREATE TABLE poi_address (
    id serial PRIMARY KEY,
    poi_id integer NOT NULL,
    address text,
    is_entrance boolean NOT NULL,
    the_geom geometry(Point,3943) NOT NULL
);
COMMENT ON TABLE poi_address IS 'Localisation du POI ou de son entree.';
COMMENT ON COLUMN poi_address.address IS 'Adresse postale de la localisation du POI.';
COMMENT ON COLUMN poi_address.is_entrance IS 'Indique sil la localisation est une entree du POI ou le barycentre du POI.';
CREATE INDEX poi_address_poi_id_idx ON poi_address USING btree (poi_id);

CREATE TABLE poi_address_accessibility (
    id serial PRIMARY KEY,
    accessibility_type_id integer NOT NULL,
    poi_address_id integer NOT NULL
    );
COMMENT ON TABLE poi_address_accessibility IS 'Acccessibilite de l''objet.';


CREATE TABLE poi_address_datasource (
    id serial PRIMARY KEY,
    poi_address_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE poi_address_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';


CREATE TABLE poi_datasource (
    id serial PRIMARY KEY,
    poi_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE poi_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE poi_type (
    id serial PRIMARY KEY,
    name character varying(50) NOT NULL,
    long_name character varying(255)
);

CREATE TABLE poi_stop (
    poi_id integer NOT NULL,
    stop_id integer NOT NULL
);
COMMENT ON TABLE poi_stop IS 'Relation entre un poi et un arrêt';
CREATE INDEX poi_stop_idx ON poi_stop USING btree (poi_id, stop_id);

CREATE TABLE printing_type
(
  id serial NOT NULL
  constraint printing_type_pkey
  primary key,
  label VARCHAR(255) DEFAULT NULL::character varying
);

CREATE TABLE printing (
    id serial PRIMARY KEY,
    quantity integer,
    "date" date,
    line_version_id integer,
    "comment" text,
    rfp_date date,
    printing_type_id integer,
    format integer NOT NULL DEFAULT 1
);
COMMENT ON TABLE printing IS 'Quantite de fiche horaire d''une offre imprimees. Aide a la gestion des document IV.';
COMMENT ON COLUMN printing.printing_type_id IS 'Raison du tirage : initial, reassort ou correction.';

CREATE TABLE printing_line_group_gis(
	id serial PRIMARY KEY,
	quantity integer,
	date date,
	line_group_gis_id integer,
	comment text
);
COMMENT ON TABLE printing_line_group_gis IS 'Quantite de voussures imprimees. Aide a la gestion des document IV.';

CREATE TABLE route (
    id serial PRIMARY KEY,
    line_version_id integer NOT NULL,
    way character varying(10),
    name character varying(100) NOT NULL,
    direction character varying(255) NOT NULL,
    comment_id integer
);
COMMENT ON TABLE route IS 'Itineraire d''une offre. ';
COMMENT ON COLUMN route.way IS 'Aller ou retour.';
COMMENT ON COLUMN route.name IS 'Nom du parcours type (Hastus ou Tigre).';
COMMENT ON COLUMN route.direction IS 'Titre de la direction, a terme, viendra de l''application girouette.';
CREATE INDEX route_line_version_id_idx ON route USING btree (line_version_id);

CREATE TABLE route_datasource (
    id serial PRIMARY KEY,
    route_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE route_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
CREATE INDEX route_datasource_code_idx ON route_datasource USING btree (code);
CREATE INDEX route_datasource_route_id_idx ON route_datasource USING btree (route_id);

CREATE TABLE route_export_destination (
    id serial PRIMARY KEY,
    route_id integer,
    export_destination_id integer
);

CREATE TABLE route_section (
    id serial PRIMARY KEY,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    the_geom geometry(LineString,3943) NOT NULL
);
COMMENT ON TABLE route_section IS 'Troncon inter-arrets provenant du referentiel de donnees geographiques. Les dates permettent de gerer des changement de parcours entre 2 arrets. Un troncon est unique pour une geometrie et ses arrets depart-arrivee.';
COMMENT ON COLUMN route_section.start_date IS 'Date de la creation de ce troncon. Un nouveau troncon est cree si arret debut ou arret fin ou geom est nouvelle.';
COMMENT ON COLUMN route_section.end_date IS 'Date de fin d''utilisation du troncon. Lorsqu''un nouveau troncon (meme debut, meme fin mais geom differente) est cree, le precedentest cloture.';
COMMENT ON COLUMN route_section.the_geom IS 'Geometrie du referentiel de donnees geographiques.';

CREATE TABLE route_stop (
    id serial PRIMARY KEY,
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
CREATE INDEX route_stop_route_id_idx ON route_stop USING btree (route_id);
CREATE INDEX route_stop_waypoint_id_idx ON route_stop USING btree (waypoint_id);


CREATE TABLE schematic (
    id serial PRIMARY KEY,
    name character varying(255),
    comment character varying(255) NOT NULL,
    date timestamp without time zone NOT NULL,
    file_path text,
    line_id integer NOT NULL,
    deprecated boolean NOT NULL,
    group_gis boolean DEFAULT FALSE
);
COMMENT ON TABLE schematic IS 'Modifications des schemas de ligne';
COMMENT ON COLUMN schematic.line_id IS 'Association d''un schematic a la line pour le proposer lors de la creation d''une line_version.';
COMMENT ON COLUMN schematic.deprecated IS 'Tag informatif sur le schematic, sans conséquence directe dans la base.';
COMMENT ON COLUMN schematic.group_gis IS 'Tag informatif sur le schematic, sans conséquence directe dans la base.';

CREATE TABLE stop_area (
    id serial PRIMARY KEY,
    short_name character varying(255) NOT NULL,
    long_name character varying(255),
    city_id integer NOT NULL,
    transfer_duration integer NOT NULL default 3,
    the_geom geometry(Point,3943)
);
COMMENT ON TABLE stop_area IS 'Zone d''arret comportant un ou plusieurs arrets.';
COMMENT ON COLUMN stop_area.short_name IS 'Nom identique aux noms des arrets le composant.';
COMMENT ON COLUMN stop_area.long_name IS 'Par defaut, le long_name est identique aux noms des arrets le composant, il peut etre modifie pour developper les abbreviations du nom court.';
COMMENT ON COLUMN stop_area.transfer_duration IS 'Temps en secondes de transfert entre deux arret de cette zone d''arrets.';
COMMENT ON COLUMN stop_area.the_geom IS 'Geometrie pour surcharger le simple centroide des stoppoint contenus dans l''area.';

CREATE TABLE stop_area_datasource (
    id serial PRIMARY KEY,
    stop_area_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE stop_area_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE stop (
    id integer PRIMARY KEY,
    stop_area_id integer,
    master_stop_id integer,
    lock boolean default false
);
COMMENT ON TABLE stop IS 'Arret de bus ou de TAD, quai de tram ou de metro.';
COMMENT ON COLUMN stop.master_stop_id IS 'Indique s''il s''agit d''un arret fictif. Reference l''id du stop reel auxquel le stop fictif est rattache.';

CREATE TABLE stop_history (
    id serial PRIMARY KEY,
    stop_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    short_name character varying(50) NOT NULL,
    long_name character varying(255),
    the_geom geometry(Point,3943) NOT NULL,
    tts_name character varying(255) DEFAULT NULL
);
COMMENT ON TABLE stop_history IS 'Proprietes d''un arret. Un arret n''a qu''un historique dans le temps. Si une caracteristique change, l''historique precedent est cloture et un nouveau est cree.';
COMMENT ON COLUMN stop_history.short_name IS 'Nom de l''arret dans le referentiel exploitation.';

CREATE TABLE stop_datasource (
    id serial PRIMARY KEY,
    stop_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE stop_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
CREATE INDEX stop_datasource_code_idx ON stop_datasource USING btree (code);
CREATE INDEX stop_datasource_stop_id_idx ON stop_datasource USING btree (stop_id);

CREATE TABLE stop_accessibility (
    id serial PRIMARY KEY,
    accessibility_type_id integer NOT NULL,
    stop_id integer NOT NULL
);
COMMENT ON TABLE stop_accessibility IS 'Acccessibilite de l''objet. Reference un mode d''accessibilite et un stop.';

CREATE TABLE stop_time (
    id serial PRIMARY KEY,
    route_stop_id integer NOT NULL,
    trip_id integer NOT NULL,
    arrival_time integer,
    departure_time integer
);
COMMENT ON TABLE stop_time IS 'Horaire d''un troncon d''itineraire.';
COMMENT ON COLUMN stop_time.arrival_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';
COMMENT ON COLUMN stop_time.departure_time IS 'Temps en seconde apres minuit de la date. Peut depasser 23h59.';
CREATE INDEX stop_time_trip_id_idx ON stop_time USING btree (trip_id);
CREATE INDEX stop_time_route_stop_id_idx ON stop_time USING btree (route_stop_id);
CREATE INDEX stop_time_route_stop_trip_idx ON stop_time (route_stop_id, trip_id);

CREATE TABLE transfer (
    id serial PRIMARY KEY,
    start_stop_id integer NOT NULL,
    end_stop_id integer NOT NULL,
    duration integer NOT NULL,
    distance integer,
    long_name character varying(255),
    the_geom geometry(Point,3943)
);
COMMENT ON TABLE transfer IS 'Correspondance entre deux arrets.';
COMMENT ON COLUMN transfer.duration IS 'Temps de transfert en secondes.';
COMMENT ON COLUMN transfer.distance IS 'Distance en metres de la correspondance.';
COMMENT ON COLUMN transfer.the_geom IS 'Trace de la correspondance.';

CREATE TABLE transfer_datasource (
    id serial PRIMARY KEY,
    transfer_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE transfer_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE transfer_accessibility (
    id serial PRIMARY KEY,
    accessibility_type_id integer NOT NULL,
    transfer_id integer NOT NULL
);
COMMENT ON TABLE transfer_accessibility IS 'Acccessibilite de l''objet. Reference un mode d''accessibilite et un transfer.';

CREATE TABLE transfer_export_destination (
    id serial PRIMARY KEY,
    transfer_id integer,
    export_destination_id integer
);

CREATE TABLE trip (
    id serial PRIMARY KEY,
    name character varying(60) NOT NULL,
    route_id integer NOT NULL,
    trip_calendar_id integer,
    comment_id integer,
    is_pattern boolean DEFAULT FALSE,
    pattern_id integer,
    trip_parent_id integer,
    day_calendar_id integer,
    period_calendar_id integer
);
COMMENT ON TABLE trip IS 'Service d''un itineraire. Fait le lien entre les horaires et les itineraires.';
COMMENT ON COLUMN trip.name IS 'Nom de l''objet. Si vient du referentiel exploitation, identique a la datasource.';
COMMENT ON COLUMN trip.trip_calendar_id IS 'Lien vers un calendrier de fiche horaire. Null si il s''agit d''un service de prod non present dans les fiches horaires.';
COMMENT ON COLUMN trip.comment_id IS 'Lien vers les commentaires pour les fiches horaires.';
COMMENT ON COLUMN trip.is_pattern IS 'TRUE si l''objet ne sert qu''a definir les temps de parcours type pour un itineraire. DAns ce cas l''objet n''est pas utilise ni dans le CI ni dans les FH.';
COMMENT ON COLUMN trip.pattern_id IS 'ID du trip reference, permet de faciliter la saisie.';
COMMENT ON COLUMN trip.trip_parent_id IS 'En cas de fusion de trip, les trip fusionnes reference l''id cree par la fusion.';
CREATE INDEX trip_route_id_idx ON trip USING btree (route_id);
CREATE INDEX trip_route_id_calendar_idx ON trip USING btree (route_id) WHERE (trip_calendar_id IS NOT NULL);
CREATE INDEX trip_day_calendar_id_idx ON trip USING btree (day_calendar_id);
CREATE INDEX trip_period_calendar_id_idx ON trip USING btree (period_calendar_id);

CREATE TABLE trip_datasource (
    id serial PRIMARY KEY,
    trip_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE trip_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';
CREATE INDEX trip_datasource_trip_id_idx ON trip_datasource USING btree (trip_id);
CREATE INDEX trip_datasource_code_idx ON trip_datasource USING btree (code);

CREATE TABLE trip_accessibility (
    id serial PRIMARY KEY,
    accessibility_type_id integer NOT NULL,
    trip_id integer NOT NULL
);
COMMENT ON TABLE trip_accessibility IS 'Acccessibilite de l''objet. Reference un mode d''accessibilite et un trip.';

CREATE TABLE trip_calendar (
    id serial PRIMARY KEY,
    grid_mask_type_id integer NOT NULL,
    monday boolean NOT NULL,
    tuesday boolean NOT NULL,
    wednesday boolean NOT NULL,
    thursday boolean NOT NULL,
    friday boolean NOT NULL,
    saturday boolean NOT NULL,
    sunday boolean NOT NULL
);
COMMENT ON TABLE trip_calendar IS 'Description des jours de circulation des services (trips) pour les fiches horaires. Table remplie par l''import du referentiel d''exploitation pour les FH.';

CREATE TABLE waypoint (
    id serial PRIMARY KEY
);
COMMENT ON TABLE waypoint IS 'Sequence commune aux stop et aux odt_area pour premettre un itineraire comme un enchainement des deux objets.';

CREATE TABLE property (
    id serial PRIMARY KEY,
    name character varying(20) NOT NULL,
    is_default boolean NOT NULL
);
COMMENT ON TABLE property IS 'Proprietes de versions de ligne';

CREATE TABLE line_version_property (
    line_version_id integer NOT NULL,
    property_id integer NOT NULL,
    "value" boolean NOT NULL,
    PRIMARY KEY (line_version_id, property_id)
);
COMMENT ON TABLE line_version_property IS 'Lien entre property et line_version';

CREATE TABLE stop_history_datasource (
    id serial PRIMARY KEY,
    stop_history_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(20)
);
COMMENT ON TABLE stop_history_datasource IS 'Reference de l''objet dans le referentiel de la datasource.';

CREATE TABLE depot (
	id serial PRIMARY KEY,
	short_name character varying(50),
	long_name character varying(255)
);
COMMENT ON TABLE depot IS 'Depot de stockage des vehicules, lie a la line_version.';
CREATE TABLE odt_geometry (
    id serial PRIMARY KEY,
    line_id integer,
    the_geom geometry(Polygon,3943)
);
COMMENT ON TABLE odt_geometry IS 'Geometrie du TAD zonal';

-- Creation des cles etrangeres
ALTER TABLE ONLY odt_geometry ADD CONSTRAINT odt_geometry_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_group_content ADD CONSTRAINT line_group_content_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_group_content ADD CONSTRAINT line_group_content_line_group_id_fk FOREIGN KEY (line_group_id) REFERENCES line_group(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_group_gis_content ADD CONSTRAINT line_group_gis_content_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_group_gis_content ADD CONSTRAINT line_group_gis_content_line_group_gis_id_fk FOREIGN KEY (line_group_gis_id) REFERENCES line_group_gis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_bg_color_id_fk FOREIGN KEY (bg_color_id) REFERENCES color(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_fg_color_id_fk FOREIGN KEY (fg_color_id) REFERENCES color(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_depot_id_fk FOREIGN KEY (depot_id) REFERENCES depot(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address_accessibility ADD CONSTRAINT poi_address_accessibility_accessibility_type_id_fk FOREIGN KEY (accessibility_type_id) REFERENCES accessibility_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address_accessibility ADD CONSTRAINT poi_address_accessibility_poi_address_id_fk FOREIGN KEY (poi_address_id) REFERENCES poi_address(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_accessibility ADD CONSTRAINT stop_accessibility_accessibility_type_id_fk FOREIGN KEY (accessibility_type_id) REFERENCES accessibility_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_accessibility ADD CONSTRAINT stop_accessibility_poi_address_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_accessibility ADD CONSTRAINT trip_accessibility_accessibility_type_id_fk FOREIGN KEY (accessibility_type_id) REFERENCES accessibility_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_accessibility ADD CONSTRAINT trip_accessibility_poi_address_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_accessibility ADD CONSTRAINT transfer_accessibility_accessibility_type_id_fk FOREIGN KEY (accessibility_type_id) REFERENCES accessibility_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_accessibility ADD CONSTRAINT transfer_accessibility_poi_address_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY accessibility_type ADD CONSTRAINT accessibility_type_accessibility_mode_id_fk FOREIGN KEY (accessibility_mode_id) REFERENCES accessibility_mode(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY accessibility_type ADD CONSTRAINT accessibility_type_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_datasource ADD CONSTRAINT route_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_datasource ADD CONSTRAINT route_datasource_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY stop_area ADD CONSTRAINT stop_area_city_id_fk FOREIGN KEY (city_id) REFERENCES city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_master_stop_id_fk FOREIGN KEY (master_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop ADD CONSTRAINT stop_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_area_datasource ADD CONSTRAINT stop_area_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_area_datasource ADD CONSTRAINT stop_area_datasource_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY stop_datasource ADD CONSTRAINT stop_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_datasource ADD CONSTRAINT stop_datasource_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY stop_history ADD CONSTRAINT stop_history_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_time ADD CONSTRAINT stop_time_route_stop_id_fk FOREIGN KEY (route_stop_id) REFERENCES route_stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_time ADD CONSTRAINT stop_time_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route ADD CONSTRAINT route_comment_id FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route ADD CONSTRAINT route_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY printing ADD CONSTRAINT printing_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY printing_line_group_gis ADD CONSTRAINT printing_line_group_gis_line_group_gis_id_fk FOREIGN KEY (line_group_gis_id) REFERENCES line_group_gis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_datasource ADD CONSTRAINT poi_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_datasource ADD CONSTRAINT poi_datasource_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY poi_address_datasource ADD CONSTRAINT poi_address_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address_datasource ADD CONSTRAINT poi_address_datasource_poi_address_id_fk FOREIGN KEY (poi_address_id) REFERENCES poi_address(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_address ADD CONSTRAINT poi_address_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_datasource ADD CONSTRAINT trip_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_datasource ADD CONSTRAINT trip_datasource_trip_id_fk FOREIGN KEY (trip_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY trip_calendar ADD CONSTRAINT grid_calendar_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip_calendar ADD UNIQUE (grid_mask_type_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday);
ALTER TABLE ONLY trip ADD CONSTRAINT trip_comment_id_fk FOREIGN KEY (comment_id) REFERENCES comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_trip_calendar_id_fk FOREIGN KEY (trip_calendar_id) REFERENCES trip_calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_export_destination ADD CONSTRAINT transfer_export_destination_exporte_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_export_destination ADD CONSTRAINT transfer_export_destination_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY transfer_datasource ADD CONSTRAINT transfer_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY transfer_datasource ADD CONSTRAINT transfer_datasource_transfer_id_fk FOREIGN KEY (transfer_id) REFERENCES transfer(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY transfer ADD CONSTRAINT transfer_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY transfer ADD CONSTRAINT transfer_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY route_export_destination ADD CONSTRAINT route_export_destination_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_export_destination ADD CONSTRAINT route_export_destination_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY route_section ADD CONSTRAINT route_section_end_stop_id_fk FOREIGN KEY (end_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY route_section ADD CONSTRAINT route_section_start_stop_id_fk FOREIGN KEY (start_stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_route_id_fk FOREIGN KEY (route_id) REFERENCES route(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_route_section_id_fk FOREIGN KEY (route_section_id) REFERENCES route_section(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY route_stop ADD CONSTRAINT route_stop_waypoint_id_fk FOREIGN KEY (waypoint_id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_stop ADD CONSTRAINT odt_stop_odt_area_id_fk FOREIGN KEY (odt_area_id) REFERENCES odt_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_stop ADD CONSTRAINT odt_stop_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY odt_area ADD CONSTRAINT odt_area_id_fk FOREIGN KEY (id) REFERENCES waypoint(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY non_concurrency ADD CONSTRAINT non_concurrency_non_priority_line_id_fk FOREIGN KEY (non_priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY non_concurrency ADD CONSTRAINT non_concurrency_priority_line_id_fk FOREIGN KEY (priority_line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY poi ADD CONSTRAINT poi_poi_type_id_fk FOREIGN KEY (poi_type_id) REFERENCES poi_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_stop ADD CONSTRAINT poi_stop_poi_id_fk FOREIGN KEY (poi_id) REFERENCES poi(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY poi_stop ADD CONSTRAINT poi_stop_stop_id_fk FOREIGN KEY (stop_id) REFERENCES stop(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_export_destination ADD CONSTRAINT line_version_export_destination_export_destination_id_fk FOREIGN KEY (export_destination_id) REFERENCES export_destination(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_export_destination ADD CONSTRAINT line_version_export_destination_line_version_id_pk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY line_version_datasource ADD CONSTRAINT line_version_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_datasource ADD CONSTRAINT line_version_datasource_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version ADD CONSTRAINT line_version_schematic_id_fk FOREIGN KEY (schematic_id) REFERENCES schematic(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_datasource ADD CONSTRAINT line_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_datasource ADD CONSTRAINT line_datasource_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY line_status ADD CONSTRAINT line_status_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line ADD CONSTRAINT line_physical_mode_fk FOREIGN KEY (physical_mode_id) REFERENCES physical_mode(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_link_calendar_mask_type ADD CONSTRAINT grid_link_calendar_mask_type_grid_calendar_id_fk FOREIGN KEY (grid_calendar_id) REFERENCES grid_calendar(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY grid_link_calendar_mask_type ADD CONSTRAINT grid_link_calendar_mask_type_grid_mask_type_id_fk FOREIGN KEY (grid_mask_type_id) REFERENCES grid_mask_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_calendar ADD CONSTRAINT grid_calendar_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY grid_mask_type ADD UNIQUE (calendar_type, calendar_period, calendar_code, scenario, included);
ALTER TABLE ONLY datasource ADD CONSTRAINT datasource_id_agency_fk FOREIGN KEY (agency_id) REFERENCES agency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY city ADD CONSTRAINT city_main_stop_area_id_fk FOREIGN KEY (main_stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY modification ADD CONSTRAINT modification_resolved_in_fk FOREIGN KEY (resolved_in) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY modification ADD CONSTRAINT modification_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_day_calendar_id_fk FOREIGN KEY (day_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_period_calendar_id_fk FOREIGN KEY (period_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_element ADD CONSTRAINT calendar_element_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_element ADD CONSTRAINT calendar_element_included_calendar_id_fk FOREIGN KEY (included_calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_datasource ADD CONSTRAINT calendar_datasource_calendar_id_fk FOREIGN KEY (calendar_id) REFERENCES calendar(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar_datasource ADD CONSTRAINT calendar_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY alias ADD CONSTRAINT alias_stop_area_id_fk FOREIGN KEY (stop_area_id) REFERENCES stop_area(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY calendar ADD CONSTRAINT calendar_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_pattern_id_fk FOREIGN KEY (pattern_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY trip ADD CONSTRAINT trip_trip_parent_id_fk FOREIGN KEY (trip_parent_id) REFERENCES trip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY schematic ADD CONSTRAINT schematic_line_id_fk FOREIGN KEY (line_id) REFERENCES line(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY line_version_property ADD CONSTRAINT line_version_property_line_version_id_fk FOREIGN KEY (line_version_id) REFERENCES line_version(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY line_version_property ADD CONSTRAINT line_version_property_property_id_fk FOREIGN KEY (property_id) REFERENCES property(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY stop_history_datasource ADD CONSTRAINT stop_history_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES datasource(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY stop_history_datasource ADD CONSTRAINT stop_history_datasource_stop_history_id_fk FOREIGN KEY (stop_history_id) REFERENCES stop_history(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY printing ADD CONSTRAINT printing_type_id_fk FOREIGN KEY (printing_type_id) REFERENCES printing_type (id);
