INSERT INTO calendar (id, name, calendar_type) VALUES (1,'cal 1','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'cal 2','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (3,'cal 3','brique') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (4,'cal 4','brique') ;
SELECT pg_catalog.setval('calendar_id_seq', 5, true);

SELECT insertcalendarelement(3,'2015-01-01','2015-02-01',NULL, '+'); -- ca marche
SELECT insertcalendarelement(1,NULL,NULL,NULL, '+', 3); -- ca marche : les calendriers 1 et 3 doivent être '2015-01-01','2015-02-01'
SELECT insertcalendarelement(3,'2015-02-01','2015-03-01',NULL, '+'); -- ca marche : 1 et 3 doivent être '2015-01-01', '2015-03-01'
SELECT insertcalendarelement(3,'2015-02-15','2015-12-01',NULL, '-'); -- ca marche : 1 et 3 doivent être '2015-01-01', '2015-02-14'
SELECT insertcalendarelement(3,'2015-01-15','2015-03-01',NULL, '&'); -- ca marche : 1 et 3 doivent être '2015-01-15', '2015-02-14'

SELECT insertcalendarelement(2,'2016-01-01','2016-04-01',NULL, '+'); -- on ajoute un calendrier 2 en 2016
SELECT insertcalendarelement(2,NULL,NULL,NULL, '&', 1); -- ca marche : le calendrier 2 doit avoir des dates NULL 

SELECT insertcalendarelement(1,'2014-01-01','2017-01-01',NULL, '+'); -- ca marche : 1 doit valoir '2014-01-01','2017-01-01' et 2 '2016-01-01','2016-04-01'

-- SELECT insertcalendarelement(4,'2015-01-01','2015-02-01',NULL, '-'); -- ca pête comme prevu
-- Le premier element d'un calendrier doit être un "+"

-- SELECT insertcalendarelement(3,'2015-02-09','2015-02-22',NULL, '+', 1); -- ca pête comme prevu
-- doit RAISE : "A calendar element with an included_calendar_id could not have start_date & end_date provided"

SELECT deletecalendarelement(3); -- ca marche : doit virer le second cal elt du calendrier 3 et mettre à jour les rank des éléments précédents


-- TEST ANTOINE
-- A1. Ajout d'un calendrier vide comme élément d'un calendrier existant.

-- création calendriers
INSERT INTO calendar (id, name, calendar_type) VALUES (1,'je suis vide','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'je vais etre rempli','periode') ;
SELECT pg_catalog.setval('calendar_id_seq', 3, true);

-- remplissages cal 2 (le cal 1 reste vide)
SELECT insertcalendarelement(2,'2015-01-01','2015-12-31',NULL, '+'); 
SELECT insertcalendarelement(2,NULL,NULL,NULL, '-', 1);
-- on vérifie que le calendar_element inséré a bien des dates début et fin à NULL ===> OK

-- remplissage cal 1
SELECT insertcalendarelement(1,'2015-08-01','2015-12-31',NULL, '+');
-- le calendar 2 doit donc valoir '2015-01-01'=>'2015-07-31' ===> OK
-- ATTENTION, start_date et end_date de calendar_element (rank 2 pour cal 2) ne sont pas mises à jour ; elles restent à NULL.

-- vidage cal 1
SELECT deletecalendarelement(3);
-- le calendrier 1 doit retrouver des computed_date à NULL, la calendrier 2 doit valoir '2015-01-01','2015-12-31' ===> KO
-- ERREUR, aucune mise à jour effectuée


