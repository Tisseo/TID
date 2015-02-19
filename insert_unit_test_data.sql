
--
-- TOC entry 3467 (class 0 OID 76830)
-- Dependencies: 174
-- Data for Name: agency; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO agency (id, name, url, timezone, lang, phone) VALUES (1, 'Réseau TEST', 'http://www.tisseo.fr', 'Europe/Paris', 'fr', NULL);


--
-- TOC entry 3483 (class 0 OID 76870)
-- Dependencies: 190
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO city(id, name, insee, main_stop_area_id) VALUES (1,'MY TOWN',31003,NULL) ;


--
-- TOC entry 3487 (class 0 OID 76880)
-- Dependencies: 194
-- Data for Name: datasource; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO datasource (id, name, agency_id) VALUES (1, 'Source 1', 1);
INSERT INTO datasource (id, name, agency_id) VALUES (2, 'Source 2', 1);


--
-- TOC entry 3497 (class 0 OID 76906)
-- Dependencies: 204
-- Data for Name: grid_mask_type; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (1, 'Semaine', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (2, 'Dimanche', 'BASE');
INSERT INTO grid_mask_type (id, calendar_type, calendar_period) VALUES (3, 'Semaine', 'Vacances');

--
-- TOC entry 3512 (class 0 OID 76954)
-- Dependencies: 219
-- Data for Name: physical_mode; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO physical_mode (id, name, type) VALUES (1, 'Métro', 'Métro');
INSERT INTO physical_mode (id, name, type) VALUES (2, 'Tramway', 'Tramway');
INSERT INTO physical_mode (id, name, type) VALUES (3, 'Bus', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (4, 'TAD', 'Bus');
INSERT INTO physical_mode (id, name, type) VALUES (5, 'Train', 'Train');
INSERT INTO physical_mode (id, name, type) VALUES (7, 'Autocar', 'Autocar');


--
-- TOC entry 3499 (class 0 OID 76911)
-- Dependencies: 206
-- Data for Name: line; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO line (id, number, physical_mode_id, priority) VALUES (1, '1', 3, 3);
INSERT INTO line (id, number, physical_mode_id, priority) VALUES (2, '2', 3, 3);
INSERT INTO line (id, number, physical_mode_id, priority) VALUES (3, '3', 3, 3);


--
-- TOC entry 3503 (class 0 OID 76921)
-- Dependencies: 210
-- Data for Name: line_version; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',1, 1, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'Grand Rond / Compans - Caffarelli', 'Grand Rond', 'Compans - Caffarelli', 'marron', '#563f00', 'yenapas.png', true, true, 'offre initiale', 'atlanta');
INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',2, 2, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'Cours Dillon / Université Paul Sabatier', 'Cours Dillon', 'Université Paul Sabatier', 'bleuclair', '#26ceff', 'yenapas.png', true, true, 'offre initiale', 'atlanta');
INSERT INTO line_version (fg_color, fg_hexa_color, id, line_id, version, start_date, end_date, planned_end_date, child_line_id, name, backward_direction, forward_direction, bg_color, bg_hexa_color, carto_file, accessibility, air_conditioned, comment, depot) VALUES ('blanc','#ffffff',3, 3, 1, '2014-09-30', NULL, '2015-06-30', NULL, 'St Cyprien - République / Oncopole', 'St Cyprien - République', 'Oncopole', 'violet', '#660099', 'yenapas.png', true, true, 'offre initiale', 'atlanta');

--
-- TOC entry 3526 (class 0 OID 76995)
-- Dependencies: 233
-- Data for Name: route; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (1,97,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (2,97,'Samedi','#a1b7e4','false','false','false','false','false','true','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (3,97,'Lundi à vendredi en vacances scolaires','#86d391','true','true','true','true','true','false','false');
INSERT INTO grid_calendar(id, line_version_id, name, color, monday, tuesday, wednesday, thursday, friday, saturday, sunday) VALUES (4,36,'Lundi à vendredi','#fdd67f','true','true','true','true','true','false','false');

INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (1,2,3,'true');
INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (2,5,3,'true');
INSERT INTO grid_link_calendar_mask_type(id, grid_calendar_id, grid_mask_type_id, active) VALUES (3,9,3,'true');

--
-- TOC entry 3552 (class 0 OID 77073)
-- Dependencies: 259
-- Data for Name: trip_calendar; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- TOC entry 3500 (class 0 OID 76914)
-- Dependencies: 207
-- Data for Name: line_datasource; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (1, 1, 1, '01');
INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (2, 2, 1, '02');
INSERT INTO line_datasource (id, line_id, datasource_id, code) VALUES (3, 3, 1, '03');


--
-- TOC entry 3504 (class 0 OID 76927)
-- Dependencies: 211
-- Data for Name: line_version_datasource; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (1, 1, 3, 'amaier');
INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (2, 2, 3, 'amaier');
INSERT INTO line_version_datasource (id, line_version_id, datasource_id, code) VALUES (3, 3, 3, 'amaier');

INSERT INTO calendar(name, calendar_type) VALUES('Dimanche', 0);
INSERT INTO calendar_datasource(calendar_id, datasource_id, code) VALUES(1, 3, '');

-- Completed on 2014-12-16 10:26:02

--
-- PostgreSQL database dump complete
--

-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 175
-- Name: agency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('agency_id_seq', 2, false);


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 177
-- Name: alias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('alias_id_seq', 1, false);


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 180
-- Name: calendar_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('calendar_datasource_id_seq', 2, false);


--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 182
-- Name: calendar_element_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('calendar_element_id_seq', 1, false);


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 183
-- Name: calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('calendar_id_seq', 2, false);


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 185
-- Name: calendar_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('calendar_link_id_seq', 1, false);



--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 187
-- Name: change_cause_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('change_cause_id_seq', 1, false);


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 189
-- Name: change_cause_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('change_cause_link_id_seq', 1, false);


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 191
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('city_id_seq', 91, false);


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 193
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('comment_id_seq', 1, false);


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 195
-- Name: datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('datasource_id_seq', 4, false);


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 197
-- Name: exception_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('exception_type_id_seq', 1, false);


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 201
-- Name: grid_calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grid_calendar_id_seq', 1, false);


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 203
-- Name: grid_link_calendar_mask_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grid_link_calendar_mask_type_id_seq', 1, false);


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 205
-- Name: grid_mask_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('grid_mask_type_id_seq', 11, false);


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 208
-- Name: line_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('line_datasource_id_seq', 110, true);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 209
-- Name: line_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('line_id_seq', 110, true);



--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 212
-- Name: line_version_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('line_version_datasource_id_seq', 110, true);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 213
-- Name: line_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('line_version_id_seq', 110, true);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 215
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('log_id_seq', 1, false);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 220
-- Name: physical_mode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('physical_mode_id_seq', 8, true);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 223
-- Name: poi_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('poi_datasource_id_seq', 1, false);

--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 226
-- Name: poi_address_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('poi_address_datasource_id_seq', 1, false);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 227
-- Name: poi_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('poi_address_id_seq', 1, false);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 228
-- Name: poi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('poi_id_seq', 1, false);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 230
-- Name: poi_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('poi_type_id_seq', 1, false);

--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 232
-- Name: printing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('printing_id_seq', 1, false);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 235
-- Name: route_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('route_datasource_id_seq', 1, false);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 236
-- Name: route_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('route_id_seq', 1, false);

--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 238
-- Name: route_section_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('route_section_id_seq', 1, false);


-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 240
-- Name: route_stop_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('route_stop_id_seq', 1, false);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 246
-- Name: stop_area_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('stop_area_datasource_id_seq', 1, false);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 247
-- Name: stop_area_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('stop_area_id_seq', 2, false);


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 249
-- Name: stop_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('stop_datasource_id_seq', 4322, false);

--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 251
-- Name: stop_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

--SELECT pg_catalog.setval('stop_history_id_seq', 1, false);


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 253
-- Name: stop_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('stop_time_id_seq', 1, false);

--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 256
-- Name: transfer_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('transfer_datasource_id_seq', 1, false);


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 257
-- Name: transfer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('transfer_id_seq', 1, false);


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 262
-- Name: trip_calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('trip_calendar_id_seq', 1, false);


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 264
-- Name: trip_datasource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('trip_datasource_id_seq', 1, false);


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 265
-- Name: trip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('trip_id_seq', 1, false);


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 242
-- Name: waypoint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('waypoint_id_seq', 4321, false);
