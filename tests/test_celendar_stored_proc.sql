INSERT INTO calendar (id, name, calendar_type) VALUES (1,'cal 1','periode');
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'cal 2','brique');
INSERT INTO calendar (id, name, calendar_type) VALUES (3,'cal 3','brique');
INSERT INTO calendar (id, name, calendar_type) VALUES (4,'cal 4','brique');
INSERT INTO calendar (id, name, calendar_type) VALUES (5,'cal 5','brique');
INSERT INTO calendar (id, name, calendar_type) VALUES (6,'cal 6','brique');
SELECT pg_catalog.setval('calendar_id_seq', 7, true);

SELECT insertcalendarelement(3,'2015-01-01','2015-02-01',1, '+'); -- ca marche
SELECT insertcalendarelement(1,NULL,NULL,1, '+', 3); -- ca marche : les calendriers 1 et 3 doivent être '2015-01-01','2015-02-01'
SELECT insertcalendarelement(3,'2015-02-01','2015-03-01',1, '+'); -- ca marche : 1 et 3 doivent être '2015-01-01', '2015-03-01'
SELECT insertcalendarelement(3,'2015-02-15','2015-12-01',1, '-'); -- ca marche : 1 et 3 doivent être '2015-01-01', '2015-02-14'
SELECT insertcalendarelement(3,'2015-01-15','2015-03-01',1, '&'); -- ca marche : 1 et 3 doivent être '2015-01-15', '2015-02-14'

SELECT getcalendarbitmask(1,'2015-01-10','2015-02-15'); -- ca marche : ça donne : "0000011111111111111111111111111111110"

SELECT insertcalendarelement(2,'2016-01-01','2016-04-01',1, '+'); -- on ajoute un calendrier 2 en 2016
SELECT insertcalendarelement(2,NULL,NULL,1, '&', 1); -- ca marche : le calendrier 2 doit avoir des dates NULL 

SELECT insertcalendarelement(1,'2014-01-01','2017-01-01',1, '+'); -- ca marche : 1 doit valoir '2014-01-01','2017-01-01' et 2 '2016-01-01','2016-04-01'

-- SELECT insertcalendarelement(4,'2015-01-01','2015-02-01',1, '-'); -- ca pête comme prevu
-- Le premier element d'un calendrier doit être un "+"

-- SELECT insertcalendarelement(3,'2015-02-09','2015-02-22',1, '+', 1); -- ca pête comme prevu
-- doit RAISE : "A calendar element with an included_calendar_id could not have start_date & end_date provided"

SELECT deletecalendarelement(3); -- ca marche : doit virer le second cal elt du calendrier 3 et mettre à jour les rank des éléments précédents




-- TEST ANTOINE




-- A1. Ajout d'un calendrier vide comme élément d'un calendrier existant.

-- création calendriers
INSERT INTO calendar (id, name, calendar_type) VALUES (1,'je suis vide','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'je vais etre rempli','periode') ;
SELECT pg_catalog.setval('calendar_id_seq', 3, true);

-- remplissages cal 2 (le cal 1 reste vide)
SELECT insertcalendarelement(2,'2015-01-01','2015-12-31',1, '+'); 
SELECT insertcalendarelement(2,NULL,NULL,1, '-', 1);
-- on vérifie que le calendar_element inséré a bien des dates début et fin à NULL ===> OK

-- remplissage cal 1
SELECT insertcalendarelement(1,'2015-08-01','2015-12-31',1, '+');
-- le calendar 2 doit donc valoir '2015-01-01'=>'2015-07-31' ===> OK
-- ATTENTION, start_date et end_date de calendar_element (rank 2 pour cal 2) ne sont pas mises à jour ; elles restent à NULL.

-- vidage cal 1
SELECT deletecalendarelement(3);
-- le calendrier 1 doit retrouver des computed_date à NULL, la calendrier 2 doit valoir '2015-01-01','2015-12-31' ===> OK


-- A2. Passage à NULL des computed_date puis suppression d'élément négatif

-- création calendriers
INSERT INTO calendar (id, name, calendar_type) VALUES (1,'je suis vide','periode') ;
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'je vais etre rempli','periode') ;
SELECT pg_catalog.setval('calendar_id_seq', 3, true);

-- remplissages cal 2 (le cal 1 reste vide)
SELECT insertcalendarelement(2,'2015-01-01','2015-01-01',1, '+'); 
SELECT insertcalendarelement(2,'2015-01-01','2015-12-31',1, '-'); 
-- les computed_date du calendrier 2 doivent être à NULL ===> OK

-- suppression rang 2 du calendrier 2
SELECT deletecalendarelement(2);
-- la suppression doit engendrer un recalcul du calendrier 2. On attend des computed_date à '2015-01-01','2015-01-01' ===> OK


-- A3. Suppression d'élément de telle sorte qu'un élément '-' arrive au premier rang

-- création calendriers
INSERT INTO calendar (id, name, calendar_type) VALUES (1,'je suis vide','periode');
INSERT INTO calendar (id, name, calendar_type) VALUES (2,'je vais etre rempli','periode');
SELECT pg_catalog.setval('calendar_id_seq', 3, true);

-- remplissages cal 2 (le cal 1 reste vide)
SELECT insertcalendarelement(2,'2015-01-01','2015-12-31',1, '+'); 
SELECT insertcalendarelement(2,NULL,NULL,1, '-', 1);

-- suppression rang 2 du calendrier 2
SELECT deletecalendarelement(2);
-- la suppression devrait être interdite ===> OK


SELECT insertcalendarelement(5,'2015-01-01','2015-02-01',1, '+'); -- les start end sont à '2015-01-01','2015-02-01'
SELECT insertcalendarelement(5,'2015-01-10','2015-01-20',1, '-'); -- les start end sont toujours à '2015-01-01','2015-02-01'
SELECT getcalendarbitmask(5,'2015-01-05','2015-02-05'); -- ca marche : ça donne : "11111000000000001111111111110000"
SELECT insertcalendarelement(5,'2015-01-15','2015-02-20',1, '-'); -- les start end sont à '2015-01-01','2015-01-09'
SELECT getcalendarbitmask(5,'2015-01-05','2015-02-05'); -- ca marche : ça donne : "11111000000000000000000000000000" 


SELECT insertcalendarelement(6,'2015-01-01','2015-03-01',2, '+'); -- les start end sont à '2015-01-01','2015-02-28'
SELECT insertcalendarelement(6,'2015-01-02','2015-03-01',2, '&'); -- les start end sont à NULL
SELECT getcalendarbitmask(6,'2015-01-01','2015-03-01'); -- vaut "000000000000000000000000000000000000000000000000000000000000"

