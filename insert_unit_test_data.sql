
INSERT INTO agency (id, name, url, timezone, lang, phone) VALUES (1, 'Réseau TEST', 'http://www.tisseo.fr', 'Europe/Paris', 'fr', NULL);

INSERT INTO datasource (id, name, agency_id) VALUES (1, 'Source 1', 1);
INSERT INTO datasource (id, name, agency_id) VALUES (2, 'Source 2', 1);


INSERT INTO city(id, name, insee, main_stop_area_id) VALUES (1,'MY TOWN',31003,NULL) ;

INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (1, 'Semaine', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (2, 'Dimanche', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (3, 'Semaine', 'Vacances');

INSERT INTO physical_mode (id, name, type) VALUES (1, 'Métro', 'Métro');
INSERT INTO physical_mode (id, name, type) VALUES (2, 'Tramway', 'Tramway');
INSERT INTO physical_mode (id, name, type) VALUES (3, 'Bus', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (4, 'TAD', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (5, 'Train', 'Train');
INSERT INTO physical_mode (id, name, type) VALUES (7, 'Autocar', 'Autocar');

INSERT INTO line (id, number, physical_mode_id, priority) VALUES (1, '1', 3, 3);
INSERT INTO line (id, number, physical_mode_id, priority) VALUES (2, '2', 3, 3);
INSERT INTO line (id, number, physical_mode_id, priority) VALUES (3, '3', 3, 3);

INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (1, 1, 1, '01');
INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (2, 2, 1, '02');
INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (3, 3, 1, '03');

INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (1, 1, 3, 'amaier');
INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (2, 2, 3, 'amaier');
INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (3, 3, 3, 'amaier');

INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',1, 1, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'Grand Rond / Compans - Caffarelli', 'Grand Rond', 'Compans - Caffarelli', 'marron', '#563f00', 'yenapas.png', true, true, 'offre initiale', 'atlanta');
INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',2, 2, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'Cours Dillon / Université Paul Sabatier', 'Cours Dillon', 'Université Paul Sabatier', 'bleuclair', '#26ceff', 'yenapas.png', true, true, 'offre initiale', 'atlanta');
INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',3, 3, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'St Cyprien - République / Oncopole', 'St Cyprien - République', 'Oncopole', 'violet', '#660099', 'yenapas.png', true, true, 'offre initiale', 'atlanta');

INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1,97,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2,97,'Samedi','#a1b7e4','false','false','false','false','false','true','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (3,97,'Lundi à vendredi en vacances scolaires','#86d391','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (4,36,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');

INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (1,2,3,'true');
INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (2,5,3,'true');
INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (3,9,3,'true');

INSERT INTO calendar(name, calendar_type) VALUES('Dimanche', 0);
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(1, 3, '');

