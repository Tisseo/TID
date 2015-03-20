INSERT INTO calendar (id, name, calendar_type) VALUES (1,'cal 1','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'cal 2','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (3,'cal 3','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (4,'cal 4','brique') ;
SELECT pg_catalog.setval('calendar_id_seq', 5, true);

SELECT insertcalendarelement(3,'2015-01-01','2015-02-01',NULL, '+'); -- ca marche
SELECT insertcalendarelement(3,'2015-02-01','2015-03-01',NULL, '+'); -- ca marche : '2015-01-01', '2015-03-01'
SELECT insertcalendarelement(3,'2015-02-15','2015-12-01',NULL, '-'); -- ca marche : '2015-01-01', '2015-02-14'
SELECT insertcalendarelement(3,'2015-01-15','2015-03-01',NULL, '&'); -- ca marche : '2015-01-15', '2015-02-14'
-- Ici le calendrier 3 doit contenir '2015-01-01','2015-03-01'

SELECT insertcalendarelement(1,NULL,NULL,NULL, '+', 3); -- ca marche
-- Ici le calendrier 1 doit contenir '2015-01-01','2015-03-01' (de même que le calendar_element qu'on vient d'insérer)

SELECT insertcalendarelement(3,'2015-02-01','2015-04-01',NULL, '+');
-- Ici les deux calendriers 1 et 3 doivent prendre les bornes '2015-01-01','2015-04-01'

-- SELECT insertcalendarelement(3,'2015-02-09','2015-02-22',NULL, '+', 1);
-- doit RAISE : "A calendar element with an included_calendar_id could not have start_date & end_date provided"

