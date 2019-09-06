BEGIN;

CREATE TABLE ogive.emergency
(
    id serial NOT NULL,
    disruption_id uuid NOT NULL,
    status integer NOT NULL,
    CONSTRAINT emergency_pkey PRIMARY KEY (id)
);

CREATE TABLE ogive.severity_color
(
    id serial NOT NULL,
    value character varying(7) NOT NULL,
    CONSTRAINT severity_color_pkey PRIMARY KEY (id)
);

INSERT INTO ogive.severity_color (value) VALUES
    ('#000000'),
    ('#FF4455'),
    ('#FF9933'),
    ('#FFFF33'),
    ('#99DD66'),
    ('#F9F9F9');

CREATE TABLE ogive.mail_template
(
    id boolean PRIMARY KEY DEFAULT TRUE,
    content text NOT NULL,
    CONSTRAINT id_uniq CHECK (id)
);

CREATE TABLE ogive.step_type
(
  id SERIAL PRIMARY KEY,
  label text,
  type INTEGER
);

CREATE TABLE ogive.template
(
  id SERIAL PRIMARY KEY,
  label character varying(255),
  "text" text
);

CREATE TABLE ogive.scenario_step_screen
(
  id SERIAL PRIMARY KEY,
  scenario_step_id INTEGER REFERENCES ogive.scenario_step (id),
  chaos_channel_id uuid
);

CREATE TABLE ogive.screen_template_section
(
  id SERIAL PRIMARY KEY,
  scenario_step_screen_id INTEGER REFERENCES ogive.scenario_step_screen (id),
  template_id INTEGER REFERENCES ogive.template(id),
  rank INTEGER,
  max_size INTEGER,
  editable BOOLEAN
);

CREATE TABLE ogive.scenario_step_info
(
  id SERIAL PRIMARY KEY,
  scenario_step_id INTEGER REFERENCES ogive.scenario_step (id),
  push BOOLEAN,
  prehome BOOLEAN,
  subtitle_template_id INTEGER REFERENCES ogive.template (id),
  content_template_id INTEGER REFERENCES ogive.template (id)
);

CREATE TABLE ogive.recipient_list
(
  id SERIAL PRIMARY KEY,
  name character varying (255),
  sort INTEGER
);

CREATE TABLE ogive.recipient
(
  id SERIAL PRIMARY KEY,
  recipient_list_id INTEGER REFERENCES ogive.recipient_list (id),
  mail character varying (255)
);

CREATE TABLE ogive.included_recipient_list
(
  recipient_list_id INTEGER REFERENCES ogive.recipient_list (id),
  included_recipient_list_id INTEGER REFERENCES ogive.recipient_list (id)
);

CREATE TABLE ogive.scenario_step_mail
(
  id serial PRIMARY KEY,
  scenario_step_id integer REFERENCES ogive.scenario_step (id),
  recipient_list_id integer,
  object_template_id integer,
  content_template_id integer
);

CREATE TABLE ogive.event_step_mail
(
  id SERIAL PRIMARY KEY,
  event_step_id INTEGER REFERENCES ogive.event_step(id),
  recipient_list_id INTEGER REFERENCES ogive.recipient_list(id),
  object text,
  content text
);

CREATE TABLE ogive.event_step_info
(
  id SERIAL PRIMARY KEY,
  event_step_id INTEGER REFERENCES ogive.event_step (id),
  push BOOLEAN,
  prehome BOOLEAN,
  priority INTEGER,
  title text,
  subtitle text,
  content text,
  modification_date timestamp without time zone
);

CREATE TABLE ogive.info_file
(
  id SERIAL PRIMARY KEY,
  filename character varying (255),
  link character varying (255),
 event_step_info_id INTEGER REFERENCES ogive.event_step_info (id)
);

CREATE TABLE ogive.event_step_screen
(
  id SERIAL PRIMARY KEY,
  event_step_id INTEGER REFERENCES ogive.event_step (id),
  chaos_channel_id uuid,
  active BOOLEAN,
  modification_date timestamp without time zone
);

CREATE TABLE ogive.screen_section
(
  id SERIAL PRIMARY KEY,
  event_step_screen_id INTEGER REFERENCES ogive.event_step_screen (id),
  rank INTEGER,
  max_size INTEGER,
  editable BOOLEAN,
  text text
);

CREATE TABLE ogive.draft
(
  id SERIAL PRIMARY KEY,
  name character varying (255),
  chaos_severity_id uuid,
  chaos_internal_cause_id uuid,
  priority INTEGER
);

CREATE TABLE ogive.draft_object
(
  id SERIAL PRIMARY KEY,
  draft_id INTEGER REFERENCES ogive.draft (id),
  object_id INTEGER REFERENCES ogive.object (id)
);

ALTER TABLE ogive.event ADD COLUMN start_publication_date timestamp without time zone;
ALTER TABLE ogive.event ADD COLUMN end_publication_date timestamp without time zone;

COMMIT;
-- migration de données
BEGIN;
-- step_type
ALTER TABLE ogive.event_step ADD step_type_id INTEGER REFERENCES ogive.step_type(id);
ALTER TABLE ogive.scenario_step ADD step_type_id INTEGER REFERENCES ogive.step_type(id);

INSERT INTO ogive.step_type (label, type) VALUES ('mail', 1);
INSERT INTO ogive.step_type (label, type) VALUES ('info', 2);
INSERT INTO ogive.step_type (label, type) VALUES ('screen', 3);

UPDATE ogive.scenario_step SET step_type_id = (SELECT id FROM ogive.step_type WHERE type = 1) WHERE connector_id = (SELECT id FROM ogive.connector WHERE connector.type = 2);
UPDATE ogive.scenario_step SET step_type_id = (SELECT id FROM ogive.step_type WHERE type = 2) WHERE connector_id = (SELECT id FROM ogive.connector WHERE connector.type = 4);
UPDATE ogive.event_step SET step_type_id = (SELECT id FROM ogive.step_type WHERE type = 1) WHERE connector_id = (SELECT id FROM ogive.connector WHERE connector.type = 2);
UPDATE ogive.event_step SET step_type_id = (SELECT id FROM ogive.step_type WHERE type = 2) WHERE connector_id = (SELECT id FROM ogive.connector WHERE connector.type = 4);

--Recipient
INSERT INTO ogive.recipient_list (id, name, sort)
(SELECT id, name, sort FROM ogive.connector_param_list);
SELECT setval('ogive.recipient_list_id_seq',(SELECT MAX(id) FROM ogive.recipient_list));

INSERT INTO ogive.recipient(recipient_list_id, mail)
(SELECT connector_param_list_id, param FROM ogive.connector_param);

INSERT INTO ogive.included_recipient_list (recipient_list_id, included_recipient_list_id)
(SELECT connector_param_list, included_connector_param_list FROM ogive.included_connector_param_list);

--template
INSERT INTO ogive.template (id, label, text)
(SELECT * FROM ogive.text);
SELECT setval ('ogive.template_id_seq', (SELECT MAX(id) FROM ogive.template));

INSERT INTO ogive.scenario_step_mail (scenario_step_id, recipient_list_id, object_template_id, content_template_id)
(
  SELECT
    scenario_step.id,
    scenario_step.connector_param_list_id,
    o.text_id,
    c.text_id
  FROM
    ogive.scenario_step JOIN
    ogive.step_type ON step_type_id = step_type.id JOIN
    ogive.scenario_step_text o ON (o.scenario_step_id = scenario_step.id AND o.text_type = 1) JOIN
    ogive.scenario_step_text c ON (c.scenario_step_id = scenario_step.id AND c.text_type = 2)
  WHERE
    step_type.type = 1
);

INSERT INTO ogive.scenario_step_info (scenario_step_id, push, prehome, subtitle_template_id, content_template_id)
(
  SELECT
    scenario_step.id,
    false,
    false,
    s.text_id,
    c.text_id
  FROM
    ogive.scenario_step JOIN
    ogive.step_type ON step_type_id = step_type.id JOIN
    ogive.scenario_step_text s ON (s.scenario_step_id = scenario_step.id AND s.text_type = 1) JOIN
    ogive.scenario_step_text c ON (c.scenario_step_id = scenario_step.id AND c.text_type = 2)
  WHERE
    step_type.type = 2
);

-- event_text
INSERT INTO ogive.event_step_mail (event_step_id, recipient_list_id, object, content)
(
  SELECT
    event_step.id,
    connector_param_list_id,
    o.text,
    c.text
  FROM
    ogive.event_step JOIN
    ogive.step_type ON step_type_id = step_type.id JOIN
    ogive.event_step_text o ON (event_step.id = o.event_step_id AND o.text_type = 1) JOIN
    ogive.event_step_text c ON (event_step.id = c.event_step_id AND c.text_type = 2)
  WHERE
    step_type.type = 1
);

INSERT INTO ogive.event_step_info (event_step_id, subtitle, content, title, modification_date, priority)
(
  SELECT
    event_step.id,
    s.text,
    c.text,
    message.title,
    message.modification_datetime,
    message.priority
  FROM
    ogive.event_step JOIN
    ogive.step_type ON step_type_id = step_type.id JOIN
    ogive.event_step_text s ON (event_step.id = s.event_step_id AND s.text_type = 1) JOIN
    ogive.event_step_text c ON (event_step.id = c.event_step_id AND c.text_type = 2) JOIN
    ogive.event ON event_step.event_id = event.id LEFT JOIN
    ogive.message ON message.id = event.message_id
  WHERE
    step_type.type = 2
);

INSERT INTO ogive.info_file (filename, link, event_step_info_id)
(
  SELECT
    filename,
    link,
    event_step_info.id
  FROM
    ogive.event_step_info JOIN
    ogive.event_step ON event_step_info.event_step_id = event_step.id JOIN
    ogive.event ON event_step.event_id = event.id JOIN
    ogive.message_file ON message_file.message_id = event.message_id
);

UPDATE ogive.event SET start_publication_date = (SELECT start_datetime FROM ogive.message WHERE id = message_id);
UPDATE ogive.event SET end_publication_date = (SELECT end_datetime FROM ogive.message WHERE id = message_id);
COMMIT;

-- suppression des anciennes tables et colonnes

BEGIN;
-- suppression de colonnes
ALTER TABLE ogive.event DROP message_id;
ALTER TABLE ogive.event_step DROP connector_id;
ALTER TABLE ogive.event_step DROP connector_param_list_id;
ALTER TABLE ogive.scenario_step DROP connector_id;
ALTER TABLE ogive.scenario_step DROP connector_param_list_id;
ALTER TABLE ogive.event_object DROP emergency_status;

-- Suppression de tables
DROP TABLE ogive.connector;
DROP TABLE ogive.connector_param;
DROP TABLE ogive.included_connector_param_list;
DROP TABLE ogive.connector_param_list;
DROP TABLE ogive.scenario_step_text;
DROP TABLE ogive.event_step_text;
DROP TABLE ogive.text;
DROP TABLE ogive.message_file;
DROP TABLE ogive.message;
DROP TABLE ogive.group_object_content;
DROP TABLE ogive.group_object;
DROP TABLE ogive.emergency_status;

COMMIT;

BEGIN;
ALTER TABLE ogive.event_step_file RENAME TO mail_file;
ALTER TABLE ogive.mail_file ADD COLUMN event_step_mail_id INTEGER REFERENCES ogive.event_step_mail(id);
ALTER TABLE ogive.mail_file RENAME COLUMN event_step_id TO event_step_id_old;

UPDATE ogive.mail_file mf SET event_step_mail_id = (SELECT id FROM ogive.event_step_mail WHERE event_step_id = mf.event_step_id_old);

ALTER TABLE ogive.mail_file DROP COLUMN event_step_id_old;

-- Ajoute une colonne deleted sur la table info_file pour indiquer si le fichier est supprimé physiquement
ALTER TABLE ogive.info_file ADD COLUMN deleted BOOLEAN DEFAULT false;

COMMIT;
