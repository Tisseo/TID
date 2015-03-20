INSERT INTO calendar (id, name, calendar_type) VALUES (1,'cal 1','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'cal 2','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (3,'cal 3','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (4,'cal 4','brique') ;
SELECT pg_catalog.setval('calendar_id_seq', 5, true);

INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (1,1,1,'2014-10-20','2014-11-02','+',1,NULL) ;
INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (2,1,2,'2015-10-19','2015-11-01','-',1,NULL) ;
INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (3,1,3,'2014-12-22','2015-01-04','&',1,NULL) ;
INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (4,2,1,'2015-12-21','2016-01-03','+',1,1) ;
INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (5,2,2,'2015-10-19','2015-11-01','-',1,NULL) ;
INSERT INTO calendar_element (calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES (6,3,1,'2015-02-09','2015-02-22','+',1,2) ;
SELECT pg_catalog.setval('calendar_element_id_seq', 7, true);

SELECT insertcalendarelement(3,'2015-02-09','2015-02-22',NULL, '+', 1);
(_calendar_id integer, _start_date date, _end_date date, _interval integer default NULL, _positive calendar_operator default '+', _included_calendar_id integer default NULL)