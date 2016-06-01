-- 05/01/2016 OGIVE V4

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- creation des tables
CREATE TABLE ogive.board
(
    id serial NOT NULL,
    short_name character varying(8) NOT NULL,
    long_name character varying(40) NOT NULL,
    nb_boards integer NOT NULL default 0,
    status character varying(50) NOT NULL,
    is_office boolean NOT NULL default false,
    is_waiting_room boolean NOT NULL default false,
    CONSTRAINT board_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.board IS 'Lieux physiques ou sont disponibles des panneaux d''affichage.';
COMMENT ON COLUMN ogive.board.is_office IS 'Le lieu est-il une agence ?';
COMMENT ON COLUMN ogive.board.is_waiting_room IS 'Le lieu est-il une salle d''attente ?';

CREATE TABLE ogive.connector
(
    id serial NOT NULL,
    name character varying(255) UNIQUE NOT NULL,
    type text NOT NULL,
    details character varying(255) NOT NULL,
    CONSTRAINT connector_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.connector_param
(
    id serial NOT NULL,
    connector_param_list_id integer NOT NULL,
    param_type character varying(40) NOT NULL,
    param character varying(255) NOT NULL,
    CONSTRAINT connector_param_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.connector_param_list
(
    id serial NOT NULL,
    name character varying(40) NOT NULL,
    sort integer NULL,
    CONSTRAINT connector_param_list_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.connector_param_list IS 'Ensemble de clé/valeur constituant la liste des paramètres. Cette liste peut elle-même inclure d''autres listes.';
COMMENT ON COLUMN ogive.connector_param_list.sort IS 'Valeur numérique permettant de trier les listes pour faciliter l''affichage.';

CREATE TABLE ogive.datasource
(
    id serial NOT NULL,
    name character varying(40) NOT NULL,
    is_editable boolean NOT NULL default true,
    CONSTRAINT datasource_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.datasource.is_editable IS 'Certaines datasources sont figées si elles proviennent d''ailleurs (TR). Le booléen est à false dans ce cas là, à true sinon.';

CREATE TABLE ogive.emergency_status
(
    id serial NOT NULL,
    rank integer NOT NULL,
    chaos_severity uuid NOT NULL,
    color character varying(20) NOT NULL,
    label character varying(40) NOT NULL,
    description character varying(255) NOT NULL,
    CONSTRAINT emergency_status_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.emergency_status IS 'Table des statuts liés au mode urgence.' ;

CREATE TABLE ogive.event
(
    id serial NOT NULL,
    chaos_severity uuid NOT NULL,
    chaos_internal_cause character varying(255) NOT NULL,
    is_published boolean,
    status integer NOT NULL,
    chaos_disruption_id uuid NOT NULL,
    reference text NULL,
    is_emergency boolean NOT NULL default false,
    login character varying(40) NOT NULL,
    event_parent_id integer NULL,
    CONSTRAINT event_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.event.reference IS 'Nom externe de l''événement, issu de CHAOS : disruption.reference. Non unique.' ;
COMMENT ON COLUMN ogive.event.is_emergency IS 'Est à true si l''événement est de type urgence. Structurant pour son apparition dans les listes.' ;
COMMENT ON COLUMN ogive.event.event_parent_id IS 'Référence à un autre événement (en cas de modification de la source par exemple).' ;

CREATE TABLE ogive.event_datasource
(
    id serial NOT NULL,
    event_id integer NOT NULL,
    datasource_id integer NOT NULL,
    code character varying(40) NULL,
    CONSTRAINT event_datasource_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.event_object
(
    id serial NOT NULL,
    event_id integer NOT NULL,
    object_id integer NOT NULL,
    emergency_status integer NULL,
    CONSTRAINT event_object_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.event_step
(
    id serial NOT NULL,
    rank integer NOT NULL,
    name character varying(255) NOT NULL,
    moment integer NOT NULL,
    mandatory boolean NOT NULL,
    event_id integer NOT NULL,
    connector_id integer NULL,
    connector_param_list_id integer NULL,
    event_step_parent_id integer NULL,
    CONSTRAINT event_step_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.event_step.rank IS 'Rang de l''étape. Les rangs sont simplement ordonnés ; ils ne se suivent pas forcément.' ;
COMMENT ON COLUMN ogive.event_step.event_step_parent_id IS 'Référence éventuelle à une étape parente, si celle-ci en dépend.' ;

CREATE TABLE ogive.event_step_text
(
    id serial NOT NULL,
    event_step_id integer NOT NULL,
    label_type character varying(40) NOT NULL,
    text character varying(255) NOT NULL,
    CONSTRAINT event_step_text_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.group_object
(
    id serial NOT NULL,
    name character varying(40) unique NOT NULL,
    group_type character varying(40) NOT NULL,
    is_private boolean NOT NULL,
    CONSTRAINT group_object_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.group_object.is_private IS 'Est à true si le groupe est interne à Tisséo (pas d''affichage à l''extérieur dans de futures listes de choix)' ;
COMMENT ON COLUMN ogive.group_object.group_type IS 'Correspond au type du groupe d''objets, par exemple pole d''échange, batiment public, groupe d''exploitation, secteur géographique... ' ;

CREATE TABLE ogive.group_object_content
(
    object_id integer NOT NULL,
    group_object_id integer NOT NULL,
    CONSTRAINT group_object_content_pkey PRIMARY KEY (object_id,group_object_id)
);

CREATE TABLE ogive.included_connector_param_list
(
    connector_param_list integer NOT NULL,
    included_connector_param_list integer NOT NULL,
    CONSTRAINT included_connector_param_list_pkey PRIMARY KEY (connector_param_list,included_connector_param_list)
);

CREATE TABLE ogive.line_board
(
    line_id integer NOT NULL,
    board_id integer NOT NULL,
    CONSTRAINT line_board_pkey PRIMARY KEY (line_id, board_id)
);

COMMENT ON TABLE ogive.line_board IS 'Le lien entre line et board est indépendant d''un système d''IV personnalisée. Il s''agit là de lier des endroits d''affichage physique à des lignes uniquement pour les affichages papier (rien à voir, en théorie, avec l''affichage numérique).' ;

CREATE TABLE ogive.line_stop
(
    id serial NOT NULL,
    stop_id integer NOT NULL,
    line_id integer NOT NULL,
    direction_name character varying(80) NOT NULL,
    CONSTRAINT line_stop_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.line_stop IS 'On utilise cette table pour créer des trios (arrêt, ligne, direction), utilisés comme des objets uniques. ' ;

CREATE TABLE ogive.link_event_step_status
(
    id serial NOT NULL,
    event_step_id integer NOT NULL,
    status integer NOT NULL,
    date_time timestamp without time zone NOT NULL,
    user_comment character varying(255) NOT NULL,
    login character varying(40) NOT NULL,
    CONSTRAINT link_event_step_status_pkey PRIMARY KEY (id),
    CONSTRAINT link_event_step_status_event_step_id_fk FOREIGN KEY (event_step_id)
          REFERENCES ogive.event_step (id) MATCH SIMPLE
              ON UPDATE RESTRICT ON DELETE RESTRICT
);

COMMENT ON TABLE ogive.link_event_step_status IS 'Dans cette table on stocke de manière exhaustive tous les changements de status d''une étape d''événement.' ;

CREATE TABLE ogive.mailbox
(
    id serial NOT NULL,
    title character varying(60) NOT NULL,
    subtitle character varying(255) NOT NULL,
    mail_text text NOT NULL,
    is_for_website boolean default false NOT NULL,
    is_for_pti boolean default false NOT NULL,
    event_id integer NULL,
    start_datetime timestamp without time zone NULL,
    end_datetime timestamp without time zone NULL,
    CONSTRAINT mailbox_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.mailbox IS 'Informations mises à disposition pour des appels venus d''ailleurs.' ;
COMMENT ON COLUMN ogive.mailbox.is_for_website is 'Est à true si l''enregistrement est à mettre à disposition des info réseau' ;
COMMENT ON COLUMN ogive.mailbox.is_for_pti is 'Est à true si l''enregistrement est à mettre à disposition de l''IV personnalisée' ;

CREATE TABLE ogive.object
(
    id serial NOT NULL,
    object_type text NOT NULL,
    object_ref character varying(255) NOT NULL,
    CONSTRAINT object_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.object.object_ref IS 'Référence de l''objet dans le référentiel lié au type (si ligne, alors TID, si mécanisme, alors PIVERT...)' ;

CREATE TABLE ogive.period
(
    id serial NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    event_id integer NOT NULL,
    CONSTRAINT period_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE ogive.period IS 'Périodes d''application de l''événement, au plus proche de l''IV. ' ;
COMMENT ON COLUMN ogive.period.is_recursive IS 'Si à true, alors les heures start_time et end_time sont pour chaque jour de la période définie. Sinon, ces horaires ne font que borner la période.' ;

CREATE TABLE ogive.scenario
(
    id serial NOT NULL,
    name character varying(255) NOT NULL,
    chaos_severity uuid NOT NULL,
    chaos_internal_cause character varying(255) NOT NULL,
    CONSTRAINT scenario_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.scenario_step
(
    id serial NOT NULL,
    rank integer NULL,
    name character varying(255) NOT NULL,
    moment integer NOT NULL,
    mandatory boolean NOT NULL,
    scenario_id integer NULL,
    connector_id integer NULL,
    connector_param_list_id integer NULL,
    scenario_step_parent_id integer NULL,
    CONSTRAINT scenario_step_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.scenario_step.rank IS 'Rang de l''étape. Les rangs sont simplement ordonnés ; ils ne se suivent pas forcément.' ;
COMMENT ON COLUMN ogive.scenario_step.scenario_step_parent_id IS 'Référence éventuelle à une étape parente, si celle-ci en dépend.' ;

CREATE TABLE ogive.scenario_step_text
(
    scenario_step_id integer NOT NULL,
    text_id integer NOT NULL,
    label character varying(40) NOT NULL,
    rank integer NOT NULL,
    CONSTRAINT scenario_step_text_pkey PRIMARY KEY (scenario_step_id, text_id)
);

COMMENT ON COLUMN ogive.scenario_step_text.label IS 'Nom du texte dans l''étape, par exemple titre, corps, sous-titre, ligne3...' ;

CREATE TABLE ogive."text"
(
    id serial NOT NULL,
    label character varying(40) NOT NULL UNIQUE,
    "text" text NOT NULL,
    CONSTRAINT text_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN ogive.text.label IS 'Nom général du texte. N''est pas structurant et n''est afférent qu''au texte seul et pas à son lien avec l''étape.' ;
COMMENT ON COLUMN ogive.text.text IS 'Texte non interprété, peut contenir des variables et fonctions.' ;



-- Creation des cles etrangeres
ALTER TABLE ONLY ogive.scenario_step_text ADD CONSTRAINT scenario_step_text_scenario_step_id_fk FOREIGN KEY (scenario_step_id) REFERENCES ogive.scenario_step(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.scenario_step_text ADD CONSTRAINT scenario_step_text_text_id_fk FOREIGN KEY (text_id) REFERENCES ogive.text(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.scenario_step ADD CONSTRAINT scenario_step_scenario_step_parent_id_fk FOREIGN KEY (scenario_step_parent_id) REFERENCES ogive.scenario_step(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.scenario_step ADD CONSTRAINT scenario_step_scenario_id_fk FOREIGN KEY (scenario_id) REFERENCES ogive.scenario(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.scenario_step ADD CONSTRAINT scenario_step_connector_id_fk FOREIGN KEY (connector_id) REFERENCES ogive.connector(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.scenario_step ADD CONSTRAINT scenario_step_connector_param_list_id_fk FOREIGN KEY (connector_param_list_id) REFERENCES ogive.connector_param_list(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_step ADD CONSTRAINT event_step_event_step_parent_id_fk FOREIGN KEY (event_step_parent_id) REFERENCES ogive.event_step(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_step ADD CONSTRAINT event_step_connector_id_fk FOREIGN KEY (connector_id) REFERENCES ogive.connector(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_step ADD CONSTRAINT event_step_connector_param_list_id_fk FOREIGN KEY (connector_param_list_id) REFERENCES ogive.connector_param_list(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_step ADD CONSTRAINT event_step_event_id_fk FOREIGN KEY (event_id) REFERENCES ogive.event(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.link_event_step_status ADD CONSTRAINT link_event_step_status_event_step_id_fk FOREIGN KEY (event_step_id) REFERENCES ogive.event_step(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_step_text ADD CONSTRAINT event_step_text_event_step_id_fk FOREIGN KEY (event_step_id) REFERENCES ogive.event_step(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.connector_param ADD CONSTRAINT connector_param_connector_param_list_id_fk FOREIGN KEY (connector_param_list_id) REFERENCES ogive.connector_param_list(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.period ADD CONSTRAINT period_event_id_fk FOREIGN KEY (event_id) REFERENCES ogive.event(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_datasource ADD CONSTRAINT event_datasource_event_id_fk FOREIGN KEY (event_id) REFERENCES ogive.event(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_datasource ADD CONSTRAINT event_datasource_datasource_id_fk FOREIGN KEY (datasource_id) REFERENCES ogive.datasource(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event ADD CONSTRAINT event_event_parent_id_fk FOREIGN KEY (event_parent_id) REFERENCES ogive.event(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_object ADD CONSTRAINT event_object_event_id_fk FOREIGN KEY (event_id) REFERENCES ogive.event(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_object ADD CONSTRAINT event_object_emergency_status_fk FOREIGN KEY (emergency_status) REFERENCES ogive.emergency_status(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.event_object ADD CONSTRAINT event_object_object_id_fk FOREIGN KEY (object_id) REFERENCES ogive.object(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.group_object_content ADD CONSTRAINT group_object_content_object_id_fk FOREIGN KEY (object_id) REFERENCES ogive.object(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.group_object_content ADD CONSTRAINT group_object_content_group_object_id_fk FOREIGN KEY (group_object_id) REFERENCES ogive.group_object(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.line_board ADD CONSTRAINT line_board_board_id_fk FOREIGN KEY (board_id) REFERENCES ogive.board(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.included_connector_param_list ADD CONSTRAINT included_connector_param_list_connector_param_list_id_fk FOREIGN KEY (connector_param_list) REFERENCES ogive.connector_param_list(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY ogive.included_connector_param_list ADD CONSTRAINT included_connector_param_list_inc_connector_param_list_id_fk FOREIGN KEY (included_connector_param_list) REFERENCES ogive.connector_param_list(id)
ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Insertion des données initiales
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('ARE','Arènes',3,'ouvert',true,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('JAU','Jean Jaurès',2,'ouvert',true,false);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('ATB','Aéroport',2,'ouvert',true,false);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('MBC','Basso Cambo',2,'ouvert',true,false);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('MAR','Marengo SNCF',2,'ouvert',true,false);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('BGR','Balma Gramont',2,'ouvert',true,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('RAM/UPS','Paul Sabatier',2,'ouvert',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('JOL','Jolimont',1,'ouvert',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('EMP','Empalot',1,'ouvert',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('ARG','Argoulets',1,'ouvert',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('BOR','Borderouge',1,'définitivement fermé',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('LVA','La Vache',1,'définitivement fermé',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('GAS','Garossos',1,'ouvert',false,true);
INSERT INTO ogive.board (short_name, long_name, nb_boards, status, is_office, is_waiting_room) VALUES ('GRT','Gare routière',3,'ouvert',false,false);

INSERT INTO ogive.datasource (name, is_editable) VALUES ('Agent métro',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Main courante',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Agent bus',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('CG31',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Police',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Mairie',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Service travaux',false);
INSERT INTO ogive.datasource (name, is_editable) VALUES ('Autre agent interne',false);

INSERT INTO ogive.connector (name, connector_type, details) VALUES ('Envoi d''email','email','Envoi d''un email à partir de l''adresse GIV') ;

INSERT INTO ogive.emergency_status (rank, chaos_severity, color, label, description) VALUES (1, '77c27c52-9903-11e5-9b8e-005056bc74dd', '#01D758', 'Trafic normal', 'Entre 96% et 100% de service');
INSERT INTO ogive.emergency_status (rank, chaos_severity, color, label, description) VALUES (2, '77c27c52-9903-11e5-9b8e-005056bc74dd', '#FFFF33', 'Trafic légèrement perturbé', 'Entre 66% et 95% de service');
INSERT INTO ogive.emergency_status (rank, chaos_severity, color, label, description) VALUES (3, '77c27c52-9903-11e5-9b8e-005056bc74dd', '#FF7F00', 'Trafic perturbé','Entre 36% et 65% de service');
INSERT INTO ogive.emergency_status (rank, chaos_severity, color, label, description) VALUES (4, '77c27c52-9903-11e5-9b8e-005056bc74dd', '#DB1702', 'Trafic fortement perturbé', 'Entre 6% et 35% de service');
INSERT INTO ogive.emergency_status (rank, chaos_severity, color, label, description) VALUES (5, '77c27c52-9903-11e5-9b8e-005056bc74dd', '#000000', 'Trafic interrompu', 'Entre 0% et 5% de service');
