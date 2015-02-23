
INSERT INTO agency (name, url, timezone, lang, phone) VALUES ('Réseau TEST', 'http://www.tisseo.fr', 'Europe/Paris', 'fr', NULL);

INSERT INTO datasource (name, agency_id) VALUES ('Source 1', 1);
INSERT INTO datasource (name, agency_id) VALUES ('Source 2', 1);

INSERT INTO city(name, insee, main_stop_area_id) VALUES ('MY TOWN',31003,NULL) ;

INSERT INTO grid_mask_type (calendar_type, calendar_period) VALUES ('Semaine', 'BASE');
INSERT INTO grid_mask_type (calendar_type, calendar_period) VALUES ('Dimanche', 'BASE');
INSERT INTO grid_mask_type (calendar_type, calendar_period) VALUES ('Semaine', 'Vacances');

INSERT INTO physical_mode (name, type) VALUES ('Métro', 'Métro');
INSERT INTO physical_mode (name, type) VALUES ('Tramway', 'Tramway');
INSERT INTO physical_mode (name, type) VALUES ('Bus', 'Bus');
INSERT INTO physical_mode (name, type) VALUES ('TAD', 'Bus');
INSERT INTO physical_mode (name, type) VALUES ('Train', 'Train');
INSERT INTO physical_mode (name, type) VALUES ('Autocar', 'Autocar');

INSERT INTO line (number, physical_mode_id, priority) VALUES ('1', 3, 3);
INSERT INTO line (number, physical_mode_id, priority) VALUES ('2', 3, 3);

INSERT INTO line_datasource (line_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO line_datasource (line_id, datasource_id, code) VALUES (2, 1, '02');

INSERT INTO line_version (line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (1, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'stadium saloon', 'saloon', 'stadium', 'bleuclair', '#26ceff', 'blanc', '#ffffff', 'yenapas.png', true, true, false, 'offre initiale', 'atlanta');
INSERT INTO line_version (line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (2, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'church saloon', 'saloon', 'church', 'bleufonce', '#0040c4', 'blanc', '#ffffff', 'yenapas.png', true, true, false, 'offre initiale', 'atlanta');


INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (2, 1, '02');

INSERT INTO grid_calendar(line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1,'Samedi','#a1b7e4','false','false','false','false','false','true','false');
INSERT INTO grid_calendar(line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2,'Lundi à vendredi en vacances scolaires','#86d391','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');

INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (1,1,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (2,1,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (3,3,'true');
INSERT INTO grid_link_calendar_mask_type(grid_calendar_id, grid_mask_type_id, active) VALUES (4,1,'true');

INSERT INTO calendar(name, calendar_type) VALUES('Dimanche', 0);
INSERT INTO calendar(name, calendar_type) VALUES('Lundi à vendredi', 0);

INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(1, 1, '01');
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(2, 1, '02');

INSERT INTO stop_area (short_name, long_name, city_id, transfer_duration, the_geom) VALUES ('church', 'Notre dames des alouettes', 1, 3, NULL);
INSERT INTO stop_area (short_name, long_name, city_id, transfer_duration, the_geom) VALUES ('saloon', 'café des sports', 1, 3, NULL);
INSERT INTO stop_area (short_name, long_name, city_id, transfer_duration, the_geom) VALUES ('stadium', 'boulodrome à dher', 1, 3, NULL);

INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO stop_area_datasource (stop_area_id, datasource_id, code) VALUES (3, 1, '03');

INSERT INTO waypoint (id) VALUES (1);
INSERT INTO waypoint (id) VALUES (2);
INSERT INTO waypoint (id) VALUES (3);
INSERT INTO waypoint (id) VALUES (4);
INSERT INTO waypoint (id) VALUES (5);
INSERT INTO waypoint (id) VALUES (6);

INSERT INTO stop (stop_area_id, master_stop_id) VALUES (1, NULL);
INSERT INTO stop (stop_area_id, master_stop_id) VALUES (1, NULL);
INSERT INTO stop (stop_area_id, master_stop_id) VALUES (2, NULL);
INSERT INTO stop (stop_area_id, master_stop_id) VALUES (2, NULL);
INSERT INTO stop (stop_area_id, master_stop_id) VALUES (3, NULL);
INSERT INTO stop (stop_area_id, master_stop_id) VALUES (3, NULL);

INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (4, 1, '04');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (5, 1, '05');
INSERT INTO stop_datasource (stop_id, datasource_id, code) VALUES (6, 1, '06');

INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (1, '2015-02-11', NULL, 'church', 'Notre dames des alouettes', '0101000020670F00003D40FB06DB0E384156903BE660594141', false);
INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (2, '2015-02-11', NULL, 'church', 'Notre dames des alouettes', '0101000020670F00009A01C0D574EF374189B43BA1584B4141', true);
INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (3, '2015-02-11', NULL, 'saloon', 'café des sports', '0101000020670F00004705C7C4D2083841C46C4A2617604141', true);
INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (4, '2015-02-11', NULL, 'saloon', 'café des sports', '0101000020670F0000DB45BCB154DD3741386E4D600E384141', false);
INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (5, '2015-02-11', NULL, 'stadium', 'boulodrome à dher', '0101000020670F0000C610AD17BAF43741B96DBF69C0494141', true);
INSERT INTO stop_history (stop_id, start_date, end_date, short_name, long_name, the_geom, accessibility) VALUES (6, '2015-02-11', NULL, 'stadium', 'boulodrome à dher', '0101000020670F0000AC15FF70D6133841BD4D80B485474141', false);

INSERT INTO route (line_version_id, way, name, direction, comment_id) VALUES (1, 'Aller', 'stadium saloon', '', NULL);
INSERT INTO route (line_version_id, way, name, direction, comment_id) VALUES (1, 'Retour', 'saloon stadium', '', NULL);
INSERT INTO route (line_version_id, way, name, direction, comment_id) VALUES (2, 'Aller', 'church saloon', '', NULL);
INSERT INTO route (line_version_id, way, name, direction, comment_id) VALUES (2, 'Retour', 'saloon church', '', NULL);

INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO route_datasource (route_id, datasource_id, code) VALUES (4, 1, '04');

INSERT INTO trip_calendar (grid_mask_type_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1, true, true, true, true, true, false, false);
INSERT INTO trip_calendar (grid_mask_type_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2, false, false, false, false, false, true, true);


INSERT INTO trip (name, route_id, trip_calendar_id, comment_id) VALUES ('15707550', 1, 1, NULL);
INSERT INTO trip (name, route_id, trip_calendar_id, comment_id) VALUES ('15707555', 2, 1, NULL);
INSERT INTO trip (name, route_id, trip_calendar_id, comment_id) VALUES ('15707558', 3, 2, NULL);
INSERT INTO trip (name, route_id, trip_calendar_id, comment_id) VALUES ('15707559', 4, 2, NULL);

INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (1, 1, '01');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (2, 1, '02');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (3, 1, '03');
INSERT INTO trip_datasource (trip_id, datasource_id, code) VALUES (4, 1, '04');

INSERT INTO route_section (start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (5, 3, '2015-02-12', NULL, '0102000020670F00000500000078307B41A2213841544228BC6E3E4141438D6327C9213841657E629B523E4141E667B8A2E421384187DF0BB73C3E414179211D232222384146C5C9DC103E41415AE002613F22384106F61803FC3D4141');
INSERT INTO route_section (start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (6, 4, '2015-02-12', NULL, '0102000020670F000004000000C23C3BF167213841037EC748963E4141C6E76716402138410E5FF020B13E414161BD38A22D21384165CBEE8EBD3E4141F6251BD6E320384131945515E23E4141');
INSERT INTO route_section (start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (1, 3, '2015-02-12', NULL, '0102000020670F000006000000AD48AFA9B6E83741A0E2973A12454141CD9EBAC13BE93741ED53E53D0E45414149CD68345BE93741683104630D454141C6C71F0C75E93741780D388D0C454141F524B81696E9374105B0751E0B4541416ED23CA615EA3741771DE07E06454141');
INSERT INTO route_section (start_stop_id, end_stop_id, start_date, end_date, the_geom) VALUES (4, 2, '2015-02-12', NULL, '0102000020670F00000800000029A56F0D9BFC374114A698A6D54E4141AC6E16A188FC3741E391915DDE4E4141A9A46F526BFC374145B58C0EED4E414179FCC56DBFFB37419B6EFE65314F4141BFECE0D5B5FB3741209EA193324F4141A223FB6CB3FB374110E10812324F4141D0AD9D10ACFB3741BF17D7592F4F4141EBFB913177FB37414BC508DA224F4141');

INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (1, 5, 0, true, true, true, false, 1, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (1, 3, 1, true, true, true, false, 1, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (2, 6, 0, true, true, true, false, 2, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (2, 4, 1, true, true, true, false, 2, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (3, 1, 0, true, true, true, false, 3, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (3, 3, 1, true, true, true, false, 3, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (4, 4, 0, true, true, true, false, 4, NULL);
INSERT INTO route_stop (route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required, route_section_id, internal_service) VALUES (4, 2, 1, true, true, true, false, 4, NULL);

INSERT INTO calendar_link (trip_id, day_calendar_id, period_calendar_id) VALUES (1, 1, 1);
INSERT INTO calendar_link (trip_id, day_calendar_id, period_calendar_id) VALUES (2, 1, 1);
INSERT INTO calendar_link (trip_id, day_calendar_id, period_calendar_id) VALUES (3, 2, 2);
INSERT INTO calendar_link (trip_id, day_calendar_id, period_calendar_id) VALUES (4, 2, 2);

INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, '2015-02-16', '2015-02-16', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, '2015-02-17', '2015-02-17', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, '2015-02-18', '2015-02-18', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, '2015-02-19', '2015-02-19', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (1, '2015-02-20', '2015-02-20', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (2, '2015-02-21', '2015-02-21', '+', NULL, NULL);
INSERT INTO calendar_element (calendar_id, start_date, end_date, positive, "interval", included_calendar_id) VALUES (2, '2015-02-22', '2015-02-22', '+', NULL, NULL);

INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (1, 1, 25200, 25200);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (1, 1, 25500, 25500);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (2, 2, 32400, 32400);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (2, 2, 32700, 32700);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (3, 3, 39600, 39600);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (3, 3, 39900, 39900);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (4, 4, 46800, 46800);
INSERT INTO stop_time (route_stop_id, trip_id, arrival_time, departure_time) VALUES (4, 4, 47100, 47100);
