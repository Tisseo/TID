
INSERT INTO agency (id, name, url, timezone, lang, phone) VALUES (1, 'Réseau TEST', 'http://www.tisseo.fr', 'Europe/Paris', 'fr', NULL);
SELECT pg_catalog.setval('agency_id_seq', 2, false);

INSERT INTO datasource (id, name, agency_id) VALUES (1, 'Source 1', 1);
INSERT INTO datasource (id, name, agency_id) VALUES (2, 'Source 2', 1);

INSERT INTO city(id, name, insee, main_stop_area_id) VALUES (1, 'MY TOWN',31003,NULL) ;

INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (1, 'Semaine', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (2, 'Dimanche', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (3, 'Semaine', 'Vacances');

INSERT INTO physical_mode (id, name, type) VALUES (1, 'Métro', 'Métro');
INSERT INTO physical_mode (id, name, type) VALUES (2, 'Tramway', 'Tramway');
INSERT INTO physical_mode (id, name, type) VALUES (3, 'Bus', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (4, 'TAD', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (5, 'Train', 'Train');
INSERT INTO physical_mode (id, name, type) VALUES (6, 'Autocar', 'Autocar');

INSERT INTO line (id, number, physical_mode_id, priority) VALUES (1, '1', 3, 3);
INSERT INTO line (id, number, physical_mode_id, priority) VALUES (2, '2', 3, 3);

INSERT INTO line_datasource (line_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO line_datasource (line_id, datasource_id, code) VALUES (2, 1, '02');

INSERT INTO line_version (id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (1, 1, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'stadium saloon', 'saloon', 'stadium', 'bleuclair', '#26ceff', 'blanc', '#ffffff', 'yenapas.png', true, true, false, 'offre initiale', 'atlanta');
INSERT INTO line_version (id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (2, 2, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'church saloon', 'saloon', 'church', 'bleufonce', '#0040c4', 'blanc', '#ffffff', 'yenapas.png', true, true, false, 'offre initiale', 'atlanta');


INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (2, 1, '02');

INSERT INTO grid_calendar(id, line_version_id, name, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1, 1,'Lundi à vendredi','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2, 1,'Samedi','false','false','false','false','false','true','false');
INSERT INTO grid_calendar(id, line_version_id, name, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (3, 2,'Lundi à vendredi en vacances scolaires','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (4, 2,'Lundi à vendredi','true','true','true','true','true','false','false');

INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (1,1,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (2,1,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (3,3,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (4,1,'true');

INSERT INTO calendar(id, name, calendar_type) VALUES(1, 'Dimanche', 'periode');
INSERT INTO calendar(id, name, calendar_type) VALUES(2, 'Lundi à vendredi', 'periode');
INSERT INTO calendar(id, name, calendar_type) VALUES(3, '785965', 'jour');
INSERT INTO calendar(id, name, calendar_type) VALUES(4, '785966', 'jour');

INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, 3, '2015-02-16', '2015-02-16', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (2, 3, '2015-02-17', '2015-02-17', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (3, 3, '2015-02-18', '2015-02-18', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (4, 3, '2015-02-19', '2015-02-19', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (5, 3, '2015-02-20', '2015-02-20', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (6, 4, '2015-02-21', '2015-02-21', '+', NULL, NULL);
INSERT INTO calendar_element (id, calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (7, 4, '2015-02-22', '2015-02-22', '+', NULL, NULL);

INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(1, 1, '01');
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(2, 1, '02');
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(3, 1, '03');
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(4, 1, '04');

INSERT INTO stop_area (id, short_name, long_name, city_id, transfer_duration, the_geom) VALUES (1, 'church', 'Notre dames des alouettes', 1, 3, NULL);
INSERT INTO stop_area (id, short_name, long_name, city_id, transfer_duration, the_geom) VALUES (2, 'saloon', 'café des sports', 1, 3, NULL);
INSERT INTO stop_area (id, short_name, long_name, city_id, transfer_duration, the_geom) VALUES (3, 'stadium', 'boulodrome à dher', 1, 3, NULL);

INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (3, 1, '03');

SELECT pg_catalog.setval('waypoint_id_seq', 1, false);
INSERT INTO waypoint DEFAULT VALUES;
INSERT INTO waypoint DEFAULT VALUES;
INSERT INTO waypoint DEFAULT VALUES;
INSERT INTO waypoint DEFAULT VALUES;
INSERT INTO waypoint DEFAULT VALUES;
INSERT INTO waypoint DEFAULT VALUES;

INSERT INTO stop (id, stop_area_id) VALUES (1, 1);
INSERT INTO stop (id, stop_area_id) VALUES (2, 1);
INSERT INTO stop (id, stop_area_id) VALUES (3, 2);
INSERT INTO stop (id, stop_area_id) VALUES (4, 2);
INSERT INTO stop (id, stop_area_id) VALUES (5, 3);
INSERT INTO stop (id, stop_area_id) VALUES (6, 3);

INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (4, 1, '04');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (5, 1, '05');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (6, 1, '06');

INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (1, 1, '2015-02-11', NULL, 'church', 'Notre dames des alouettes', '0101000020670F00003D40FB06DB0E384156903BE660594141', false);
INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (2, 2, '2015-02-11', NULL, 'church', 'Notre dames des alouettes', '0101000020670F00009A01C0D574EF374189B43BA1584B4141', true);
INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (3, 3, '2015-02-11', NULL, 'saloon', 'café des sports', '0101000020670F00004705C7C4D2083841C46C4A2617604141', true);
INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (4, 4, '2015-02-11', NULL, 'saloon', 'café des sports', '0101000020670F0000DB45BCB154DD3741386E4D600E384141', false);
INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (5, 5, '2015-02-11', NULL, 'stadium', 'boulodrome à dher', '0101000020670F0000C610AD17BAF43741B96DBF69C0494141', true);
INSERT INTO stop_history (id, stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (6, 6, '2015-02-11', NULL, 'stadium', 'boulodrome à dher', '0101000020670F0000AC15FF70D6133841BD4D80B485474141', false);

INSERT INTO route (id, line_version_id, way, name, direction, comment_id) VALUES (1, 1, 'Aller', 'stadium saloon', '', NULL);
INSERT INTO route (id, line_version_id, way, name, direction, comment_id) VALUES (2, 1, 'Retour', 'saloon stadium', '', NULL);
INSERT INTO route (id, line_version_id, way, name, direction, comment_id) VALUES (3, 2, 'Aller', 'church saloon', '', NULL);
INSERT INTO route (id, line_version_id, way, name, direction, comment_id) VALUES (4, 2, 'Retour', 'saloon church', '', NULL);

INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (4, 1, '04');

INSERT INTO trip_calendar (id, grid_mask_type_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1, 1, true, true, true, true, true, false, false);
INSERT INTO trip_calendar (id, grid_mask_type_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2, 2, false, false, false, false, false, true, true);

INSERT INTO trip (id, name, route_id, trip_calendar_id, comment_id, day_calendar_id, period_calendar_id) VALUES (1, '15707550', 1, 1, NULL, 3, NULL);
INSERT INTO trip (id, name, route_id, trip_calendar_id, comment_id, day_calendar_id, period_calendar_id) VALUES (2, '15707555', 2, 1, NULL, 3, NULL);
INSERT INTO trip (id, name, route_id, trip_calendar_id, comment_id, day_calendar_id, period_calendar_id) VALUES (3, '15707558', 3, 2, NULL, 4, NULL);
INSERT INTO trip (id, name, route_id, trip_calendar_id, comment_id, day_calendar_id, period_calendar_id) VALUES (4, '15707559', 4, 2, NULL, 4, NULL);

INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (4, 1, '04');

INSERT INTO route_section (id, start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (1, 5, 3, '2015-02-12', NULL, '0102000020670F00000500000078307B41A2213841544228BC6E3E4141438D6327C9213841657E629B523E4141E667B8A2E421384187DF0BB73C3E414179211D232222384146C5C9DC103E41415AE002613F22384106F61803FC3D4141');
INSERT INTO route_section (id, start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (2, 6, 4, '2015-02-12', NULL, '0102000020670F000004000000C23C3BF167213841037EC748963E4141C6E76716402138410E5FF020B13E414161BD38A22D21384165CBEE8EBD3E4141F6251BD6E320384131945515E23E4141');
INSERT INTO route_section (id, start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (3, 1, 3, '2015-02-12', NULL, '0102000020670F000006000000AD48AFA9B6E83741A0E2973A12454141CD9EBAC13BE93741ED53E53D0E45414149CD68345BE93741683104630D454141C6C71F0C75E93741780D388D0C454141F524B81696E9374105B0751E0B4541416ED23CA615EA3741771DE07E06454141');
INSERT INTO route_section (id, start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (4, 4, 2, '2015-02-12', NULL, '0102000020670F00000800000029A56F0D9BFC374114A698A6D54E4141AC6E16A188FC3741E391915DDE4E4141A9A46F526BFC374145B58C0EED4E414179FCC56DBFFB37419B6EFE65314F4141BFECE0D5B5FB3741209EA193324F4141A223FB6CB3FB374110E10812324F4141D0AD9D10ACFB3741BF17D7592F4F4141EBFB913177FB37414BC508DA224F4141');

INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (1, 1, 5, 0, true, true, true, false, 1, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (2, 1, 3, 1, true, true, true, false, 1, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (3, 2, 6, 0, true, true, true, false, 2, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (4, 2, 4, 1, true, true, true, false, 2, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (5, 3, 1, 0, true, true, true, false, 3, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (6, 3, 3, 1, true, true, true, false, 3, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (7, 4, 4, 0, true, true, true, false, 4, NULL);
INSERT INTO route_stop (id, route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (8, 4, 2, 1, true, true, true, false, 4, NULL);

INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (1, 1, 1, 25200, 25200);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (2, 1, 1, 25500, 25500);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (3, 2, 2, 32400, 32400);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (4, 2, 2, 32700, 32700);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (5, 3, 3, 39600, 39600);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (6, 3, 3, 39900, 39900);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (7, 4, 4, 46800, 46800);
INSERT INTO stop_time (id, route_stop_id, trip_id, arrival_time, departure_time) VALUES (8, 4, 4, 47100, 47100);

INSERT INTO poi_type(name) VALUES ('poi_type1');