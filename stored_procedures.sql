SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE FUNCTION cleanimport() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        DELETE FROM route_datasource;
        DELETE FROM trip_datasource;
        DELETE FROM stop_time;
        DELETE FROM route_stop;
        DELETE FROM calendar_datasource;
        DELETE FROM calendar_element;
        DELETE FROM calendar;
        DELETE FROM trip;
        DELETE FROM trip_calendar;
        DELETE FROM route;
        DELETE FROM stop_datasource;
        DELETE FROM stop_history;
        DELETE FROM route_section;
        DELETE FROM stop;
        DELETE FROM waypoint;
        DELETE FROM stop_area_datasource;
        DELETE FROM stop_area;
    END;
    $$;
COMMENT ON FUNCTION cleanimport() IS 'Fonction de debug, suppression des données relatives aux imports HASTUS.';


CREATE FUNCTION cleanpoi() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        DELETE FROM poi_datasource;
        DELETE FROM poi_address;
        DELETE FROM poi;
        DELETE FROM poi_type;
    END;
    $$;
COMMENT ON FUNCTION cleanpoi() IS 'Fonction de suppression des données POI, appelée à chaque nouvel import provenant de la base SIG.';


CREATE FUNCTION insertcalendar(_name character varying, _ccode character varying, _datasource integer, _calendar_type calendar_type default 'periode') RETURNS integer 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _calendar_id integer;
    BEGIN
        INSERT INTO calendar(name, calendar_type) VALUES (_name, _calendar_type) RETURNING id INTO _calendar_id;
        INSERT INTO calendar_datasource(calendar_id, code, datasource_id) VALUES (_calendar_id, _ccode, _datasource);
        RETURN _calendar_id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendar (character varying, character varying, integer, calendar_type) IS 'insert record in tables calendar and calendar_datasource and return new calendar.id';


CREATE FUNCTION insertcalendarelement(_calendar_id integer, _start_date date, _end_date date, _interval integer default NULL, _positive calendar_operator default '+', _included_calendar_id integer default NULL) RETURNS integer 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _id integer;
    BEGIN
        INSERT INTO calendar_element(calendar_id, start_date, end_date, positive, interval, included_calendar_id) VALUES(_calendar_id, _start_date, _end_date, _positive, _interval, _included_calendar_id) RETURNING id INTO _id;
        RETURN _id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendarelement (integer, date, date, integer, calendar_operator, integer) IS 'Insert record in table calendar_element and return new id';


CREATE FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer,  _positive calendar_operator default '+') RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _route_id integer;
        _trip_id integer;
        _calendar_id integer;
    BEGIN
        -- Check route and trip exist and raise if not
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON RD.route_id = R.id WHERE R.line_version_id = _lvid AND RD.code = _rcode;
        IF _route_id IS NULL THEN
            RAISE EXCEPTION 'route not found with code %s and line_version_id %s', _rcode, _lvid;
        ELSE
            SELECT T.id INTO _trip_id FROM trip T JOIN trip_datasource TD ON TD.trip_id = T.id WHERE TD.code = _tcode AND T.route_id = _route_id;
            IF _trip_id IS NULL THEN
                RAISE EXCEPTION 'trip not found with code %s and route_id %s', _tcode, _route_id;
            END IF;
        END IF;
        -- Check the calendar already exist, if it doesn't add it with its datasource and link it to its related trip, else, add new calendar_element
        -- Any case : Insert new calendar_element
        SELECT T.period_calendar_id INTO _calendar_id FROM trip T WHERE T.id = _trip_id;
        IF _calendar_id IS NULL THEN
            INSERT INTO calendar(name, calendar_type, line_version_id) VALUES (_name, 'periode', _lvid);
            INSERT INTO calendar_datasource(calendar_id, code, datasource_id) VALUES (currval('calendar_id_seq'), _tcode, _datasource);
            UPDATE trip SET period_calendar_id =  currval('calendar_id_seq') WHERE id = _trip_id;
            INSERT INTO calendar_element(calendar_id, start_date, end_date, positive) VALUES(currval('calendar_id_seq'), _date, _date, _positive);
        ELSE
            INSERT INTO calendar_element(calendar_id, start_date, end_date, positive) VALUES(_calendar_id, _date, _date, _positive);
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer, _positive calendar_operator) IS 'Insertion selon condition de nouvelles entrées calendar, calendar_datasource et calendar_element plus mise à jour dune entrée trip associée à ces nouveaux calendriers. Si le calendrier rattaché au trip existe déjà lors de lappel de cette fonction, elle effectuera une simple insertion dune entrée calendar_element.';

CREATE TYPE address AS (address character varying, the_geom character varying, is_entrance boolean);

CREATE FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _type_id integer;
        _poi_id integer;
        _real_geom pgis.geometry(Point, 3943);
        _address address;
    BEGIN
        IF _is_velo THEN
		-- When boolean _is_velo is True, the _type parameter (for poi_type)
        -- which usually references a poi_type.name is in fact directly the 
        -- poi_type.id. Bicycles poi are persisted from a different
        -- loop in the import script and their poi_type is always the same.
            _type_id := _type::integer;
        ELSE
            SELECT id INTO _type_id FROM poi_type WHERE name = _type;
            IF _type_id IS NULL THEN
                INSERT INTO poi_type(name) VALUES(_type) RETURNING id INTO _type_id;
            END IF;
        END IF;
        INSERT INTO poi(name, city_id, poi_type_id, priority) VALUES (_name, _city_id, _type_id, _priority) RETURNING id INTO _poi_id;
        INSERT INTO poi_datasource(poi_id, code, datasource_id) VALUES (_poi_id, '', _datasource);
        FOREACH _address IN ARRAY addresses
        LOOP
            _real_geom := pgis.ST_GeomFromText(_address.the_geom, 3943);
            INSERT INTO poi_address(poi_id, address, is_entrance, the_geom) VALUES (_poi_id, _address.address, _address.is_entrance, _real_geom);
        END LOOP;
    END;
    $$;
COMMENT ON FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) IS 'Insertion de nouvelles entrées poi, poi_datasource et si passées en paramètre, poi_adress. Les poi_adress sont passées dans le tableau addresses qui contient des types address (le type address est un type technique contenant les champs nécessaires à linsertion dune entrée poi_address). Ainsi toutes les entrées poi_address seront associées à la donnée poi nouvellement créée.';


CREATE FUNCTION insertroute(_lvid integer, _way character varying, _name character varying, _direction character varying, _code character varying, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO route(line_version_id, way, name, direction) VALUES (_lvid, _way, _name, _direction);
        INSERT INTO route_datasource(route_id, datasource_id, code) VALUES (currval('route_id_seq'), _datasource, _code);
    END;
    $$;
COMMENT ON FUNCTION insertroute (integer, character varying, character varying, character varying, character varying, integer) IS 'Insert record in tables route and route_datasource.';


CREATE FUNCTION insertroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _real_geom pgis.geometry(Linestring, 3943);
    BEGIN
        _real_geom := pgis.ST_GeomFromText(_the_geom, 3943);
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$;
COMMENT ON FUNCTION insertroutesection (integer, integer, character varying, date) IS 'Insert record in table route_section.';


CREATE FUNCTION insertroutestopandstoptime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _route_stop_id integer;
        _route_section_id integer;
        _route_id integer;
        _trip_id integer;
        _stop_id integer;
        _related_stop_id integer;
    BEGIN
        SELECT W.id INTO _stop_id FROM waypoint W JOIN stop S ON S.id = W.id JOIN stop_datasource SD ON SD.stop_id = S.id WHERE SD.code = _scode;
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON RD.route_id = R.id WHERE RD.code = _rcode AND R.line_version_id = _lvid;
        SELECT RS.id INTO _route_stop_id FROM route_stop RS WHERE RS.route_id = _route_id AND RS.waypoint_id = _stop_id AND RS.rank = _rank;
        IF _route_stop_id IS NULL THEN
            SELECT W.id INTO _related_stop_id FROM waypoint W JOIN stop S ON S.id = W.id JOIN stop_datasource SD ON SD.stop_id = S.id WHERE SD.code = _related_scode;
            -- _is_last and _is_first booleans :
            --      _is_first         : pickup = True   | dropoff = False   | route_section (start_stop = _stop_id / end_stop = _related_stop_id)
            --      _is_last          : pickup = False  | dropoff = True    | no route_section added
            --      neither of them   : pickup = True   | dropoff = True    | route_section (start_stop = _stop_id / end_stop = _related_stop_id)
            IF _is_last THEN
                INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, False, True, False) RETURNING id INTO _route_stop_id;
            ELSE
                SELECT RE.id INTO _route_section_id FROM route_section RE WHERE start_stop_id = _stop_id AND end_stop_id = _related_stop_id;
                IF _is_first IS TRUE THEN
                    INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, route_section_id, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, _route_section_id, True, False, False) RETURNING id INTO _route_stop_id;
                ELSE
                    INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, route_section_id, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, _route_section_id, True, True, False) RETURNING id INTO _route_stop_id;
                END IF;
            END IF;
        END IF;
        SELECT T.id INTO _trip_id FROM trip T JOIN trip_datasource TD ON TD.trip_id = T.id WHERE TD.code = _tcode AND T.route_id = _route_id; 
        INSERT INTO stop_time(route_stop_id, trip_id, departure_time, arrival_time) VALUES (_route_stop_id, _trip_id, _hour, _hour);
    END;
    $$;
COMMENT ON FUNCTION insertroutestopandstoptime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean) IS 'Insertion dune nouvelle entrée dans route_stop si elle nexiste pas déjà. Insertion dune nouvelle entrée stop_time. Dans le cas dinsertion dun route_stop, certaines valeurs changent en fonction du rang du route_stop dans litinéraire. Chaque route_stop est rattaché à une route_section sauf le dernier (doublon avec lavant dernier sinon). Les booléens pickup/dropoff prennent également des valeur différentes selon le rang du route_stop.';

CREATE FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _code character varying, _insee character varying, _datasource integer, _srid integer default 27572) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _stop_id integer;
        _stop_area_id integer;
		_accessibility_type_id integer;
		_calendar_id integer;
        _the_geom pgis.geometry(Point, 3943);
        _temp_geom character varying;
    BEGIN
        SELECT SA.id INTO _stop_area_id FROM stop_area SA JOIN city C ON C.id = SA.city_id WHERE SA.short_name = _name AND C.insee = _insee;
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := pgis.ST_Transform(pgis.ST_GeomFromText(_temp_geom, _srid), 3943);

        IF _stop_area_id IS NULL THEN
            RAISE EXCEPTION 'stop area not found with this short_name % and city %', _name, _insee;
        ELSE
            INSERT INTO waypoint(id) VALUES (nextval('waypoint_id_seq')) RETURNING waypoint.id INTO _stop_id;
            INSERT INTO stop(id, stop_area_id) VALUES (_stop_id, _stop_area_id);
            INSERT INTO stop_datasource(stop_id, datasource_id, code) VALUES (_stop_id, _datasource, _code);
            INSERT INTO stop_history(stop_id, start_date, short_name, the_geom) VALUES (_stop_id, _date, _name, _the_geom);
			
			PERFORM setstopaccessibility(_stop_id, _access, _accessibility_mode_id, _code, _datasource);			
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _code character varying, _insee character varying, _datasource integer, _srid integer) IS 'Insertion de 4 nouvelles entrées : un waypoint et un stop qui possèderont le même ID, puis les stop_datasource et stop_history associés au nouveau stop. La géométrie du stop_history est construite depuis des valeurs x/y passées en paramètre. Ces valeurs sont issues dun SRID 27572 (sortie HASTUS) et la géométrie finale est passée en SRID 3943.';


CREATE FUNCTION insertstoparea(_city_id integer, _name character varying, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _stop_area_id integer;
    BEGIN
        INSERT INTO stop_area(short_name, long_name, city_id, transfer_duration) VALUES(_name, _name, _city_id, 3) RETURNING stop_area.id INTO _stop_area_id;
        INSERT INTO stop_area_datasource(stop_area_id, datasource_id, code) VALUES(_stop_area_id, _datasource, null);
    END;
    $$;
COMMENT ON FUNCTION insertstoparea (integer, character varying, integer) IS 'Insertion dune entrée stop_area et de sa datasource associée.';


CREATE FUNCTION inserttrip(_name character varying, _tcode character varying, _rcode character varying, _lvid integer, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _route_id integer;
    BEGIN
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON R.id = RD.route_id WHERE RD.code = _rcode AND R.line_version_id = _lvid;
        INSERT INTO trip(name, route_id) VALUES (_name, _route_id);
        INSERT INTO trip_datasource(trip_id, datasource_id, code) VALUES (currval('trip_id_seq'), _datasource, _tcode);
    END;
    $$;
COMMENT ON FUNCTION inserttrip (character varying, character varying, character varying, integer, integer) IS 'Insertion dun nouveau trip et de sa datasource associée. Le trip est directement rattaché à une route dont lid est récupéré grâce aux paramètres _rcode et _lvid.';


CREATE FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _real_geom pgis.geometry(Linestring, 3943);
    BEGIN
        _real_geom := pgis.ST_GeomFromText(_the_geom, 3943);
        UPDATE route_section SET end_date = _end_date WHERE id = _route_section_id;
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$;
COMMENT ON FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) IS 'La mise à jour dune route_section est historisée. Cela implique la fermeture dune route_section (champ end_date prend une valeur) et la création de sa successeur avec un champ end_date vide.';


CREATE FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _stop_id integer;
        _temp_geom character varying;
        _the_geom pgis.geometry(Point, 3943);
    BEGIN
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := pgis.ST_Transform(pgis.ST_GeomFromText(_temp_geom, 27572), 3943);
        UPDATE stop_history SET end_date = _date - interval '1 day' WHERE id = _stop_history_id RETURNING stop_id INTO _stop_id;
        INSERT INTO stop_history(stop_id, start_date, short_name, the_geom) VALUES (_stop_id, _date, _name, _the_geom);
		
		-- si master_stop_id est null, update l'accessibilite
    END;
    $$;
COMMENT ON FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean) IS 'La mise à jour dun stop est historisée. Cela implique la fermeture de la version courante dun stop_history en appliquant une date au champ end_date puis en la création de son successeur avec un champ end_date vide.';


CREATE FUNCTION insertline(_number character varying, _physical_mode_id integer, _line_code character varying, _datasource integer, _priority integer default 0)
    RETURNS integer AS $$
    DECLARE
        _line_id integer;
    BEGIN
        INSERT INTO line (number, physical_mode_id, priority) VALUES (_number, _physical_mode_id, _priority) RETURNING line.id INTO _line_id;
        INSERT INTO line_datasource (line_id, datasource_id, code) VALUES (_line_id, _datasource, _line_code);
        RETURN _line_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertline (character varying, integer, character varying, integer, integer) IS 'Insert record in tables line and line_datasource and return the new line.id';


CREATE FUNCTION insertlineversion(_line_id integer, _version integer, _start_date date, _end_date date, _planned_end_date date, _child_line_id integer, _name character varying, _forward_direction character varying, _backward_direction character varying, _bg_color character varying, _bg_hexa_color character varying, _fg_color character varying, _fg_hexa_color character varying, _carto_file text, _accessibility boolean, _air_conditioned boolean, _certified boolean, _comment text, _depot character varying, _datasource integer, _code character varying)
    RETURNS integer AS $$
    DECLARE
        _line_version_id integer;
    BEGIN
		UPDATE line_version SET end_date = current_date WHERE end_date IS NULL AND line_id = _line_id;
        INSERT INTO line_version (line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (_line_id, _version, _start_date, _end_date, _planned_end_date, _child_line_id, _name, _forward_direction, _backward_direction, _bg_color, _bg_hexa_color, _fg_color, _fg_hexa_color, _carto_file, _accessibility, _air_conditioned, _certified, _comment, _depot) RETURNING line_version.id INTO _line_version_id;
        INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (_line_version_id, _datasource, _code);
        RETURN _line_version_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertlineversion (integer, integer, date, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text, boolean, boolean, boolean, text, character varying, integer, character varying) IS 'Insert record in tables line_version and line_version_datasource and return the new line_version.id';


CREATE FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _calendar_id integer;
    BEGIN			
		SELECT calendar_id INTO _calendar_id
		FROM accessibility_type a
		JOIN stop_accessibility s ON s.accessibility_type_id = a.id
		WHERE a.accessibility_mode_id = _accessibility_mode_id
		AND s.stop_id = _stop_id;
		
		IF _access THEN
			IF _calendar_id IS NOT NULL THEN
				UPDATE calendar_element
				SET end_date = current_date
				WHERE calendar_id = _calendar_id;			
			END IF;
		ELSE
			IF _calendar_id IS NOT NULL THEN
				UPDATE calendar_element
				SET start_date = current_date,
						end_date = date '2999-12-31'
				WHERE calendar_id = _calendar_id;
			ELSE
				SELECT insertcalendar('Access_'|| _accessibility_mode_id, _code, _datasource, 'accessibilite')  INTO _calendar_id;
				PERFORM insertcalendarelement(_calendar_id, current_date, date '2999-12-31');
				INSERT INTO accessibility_type(accessibility_mode_id, calendar_id) VALUES (_accessibility_mode_id, currval('calendar_id_seq'));
				INSERT INTO stop_accessibility(accessibility_type_id, stop_id) VALUES (currval('accessibility_type_id_seq'), _stop_id);			
			END IF;
		END IF;
    END;
    $$;
COMMENT ON FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer) IS 'Insert or update access(_access)  for an accessibility mode(_accessibility_mode_id) for the selected stop(_stop_id) and return the new stop_accessibility.id. _code is used,  if necessary, for the associated calendar.name ';


CREATE FUNCTION stopisaccessible(_stop_id integer, _accessibility_mode_id integer, _date date default null)
    RETURNS boolean AS $$
    DECLARE
        _calendar_id integer;
		_calendar_element_id integer;
		_accessibility_date date;
		_result boolean;
    BEGIN
		IF _date IS NULL THEN
			_accessibility_date := current_date;
		ELSE
			_accessibility_date := _date;		
		END IF;
		SELECT calendar_id INTO _calendar_id
		FROM accessibility_type a
		JOIN stop_accessibility s ON s.accessibility_type_id = a.id
		WHERE a.accessibility_mode_id = _accessibility_mode_id
		AND s.stop_id = _stop_id;
		
		_result := true;
		IF _calendar_id IS NOT NULL THEN
			SELECT id INTO _calendar_element_id
			FROM calendar_element
			WHERE calendar_id = _calendar_id
			AND (start_date > _accessibility_date 
			OR end_date <= _accessibility_date);
			
			IF _calendar_element_id IS NULL THEN
				-- calendar element exists but not for this where clause
				_result := false;
			ELSE
				_result := true;
			END IF;
		END IF;

		RETURN _result;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION stopisaccessible(_stop_id integer, _accessibility_mode_id integer, _date date) IS 'return true if _stop_id is accessible. Function tests next day accessibility';

