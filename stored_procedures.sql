CREATE OR REPLACE FUNCTION InsertStop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _code character varying, _insee character varying, _datasource integer)
    RETURNS void AS $$
    DECLARE
        _stop_id integer;
        _stop_area_id integer;
        _the_geom geometry(Point, 3943);
        _temp_geom character varying;
    BEGIN
        SELECT SA.id INTO _stop_area_id FROM stop_area SA JOIN city C ON C.id = SA.city_id WHERE SA.short_name = _name AND C.insee = _insee;
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := ST_Transform(ST_GeomFromText(_temp_geom, 27572), 3943);

        IF _stop_area_id IS NULL THEN
            RAISE EXCEPTION 'stop area not found with this short_name % and city %', _name, _insee;
        ELSE
            INSERT INTO waypoint(id) VALUES (nextval('waypoint_id_seq')) RETURNING waypoint.id INTO _stop_id;
            INSERT INTO stop(id, stop_area_id) VALUES (_stop_id, _stop_area_id);
            INSERT INTO stop_datasource(stop_id, datasource_id, code) VALUES (_stop_id, _datasource, _code);
            INSERT INTO stop_history(stop_id, start_date, short_name, the_geom, accessibility) VALUES (_stop_id, _date, _name, _the_geom, _access);
        END IF;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION UpdateStop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean)
    RETURNS void AS $$
    DECLARE
        _stop_id integer;
        _temp_geom character varying;
        _the_geom geometry(Point, 3943);
    BEGIN
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := ST_Transform(ST_GeomFromText(_temp_geom, 27572), 3943);
        UPDATE stop_history SET end_date = _date - interval '1 day' WHERE id = _stop_history_id RETURNING stop_id INTO _stop_id;
        INSERT INTO stop_history(stop_id, start_date, short_name, the_geom, accessibility) VALUES (_stop_id, _date, _name, _the_geom, _access);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertStopArea(_city_id integer, _name character varying, _datasource integer)
    RETURNS VOID AS $$
    DECLARE
        _stop_area_id integer;
    BEGIN
        INSERT INTO stop_area(short_name, long_name, city_id, transfer_duration) VALUES(_name, _name, _city_id, 3) RETURNING stop_area.id INTO _stop_area_id;
        INSERT INTO stop_area_datasource(stop_area_id, datasource_id, code) VALUES(_stop_area_id, _datasource, null);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertRoute(_lvid integer, _way character varying, _name character varying, _direction character varying, _code character varying, _datasource integer)
    RETURNS VOID AS $$
    BEGIN
        INSERT INTO route(line_version_id, way, name, direction) VALUES (_lvid, _way, _name, _direction);
        INSERT INTO route_datasource(route_id, datasource_id, code) VALUES (currval('route_id_seq'), _datasource, _code);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertTrip(_name character varying, _tcode character varying, _rcode character varying, _lvid integer, _datasource integer)
    RETURNS VOID AS $$
    DECLARE
        _route_id integer;
    BEGIN
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON R.id = RD.route_id WHERE RD.code = _rcode AND R.line_version_id = _lvid;
        INSERT INTO trip(name, route_id) VALUES (_name, _route_id);
        INSERT INTO trip_datasource(trip_id, datasource_id, code) VALUES (currval('trip_id_seq'), _datasource, _tcode);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertCalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer)
    RETURNS VOID AS $$
    DECLARE
        _route_id integer;
        _trip_id integer;
        _calendar_id integer;
        _day_calendar_id integer;
    BEGIN
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON RD.route_id = R.id WHERE R.line_version_id = _lvid AND RD.code = _rcode;
        IF _route_id IS NULL THEN
            RAISE EXCEPTION 'route not found with code %s and line_version_id %s', _rcode, _lvid;
        ELSE
            SELECT T.id INTO _trip_id FROM trip T JOIN trip_datasource TD ON TD.trip_id = T.id WHERE TD.code = _tcode AND T.route_id = _route_id;
            IF _trip_id IS NULL THEN
                RAISE EXCEPTION 'trip not found with code %s and route_id %s', _tcode, _route_id;
            END IF;
        END IF;
        IF NOT EXISTS (SELECT CL.id FROM calendar_link CL WHERE CL.trip_id = _trip_id) THEN
            SELECT id INTO _day_calendar_id FROM calendar WHERE name = 'Dimanche';
            INSERT INTO calendar(name, calendar_type) VALUES (_name, 1);
            INSERT INTO calendar_datasource(calendar_id, code, datasource_id) VALUES (currval('calendar_id_seq'), _tcode, _datasource);
            INSERT INTO calendar_link(trip_id, period_calendar_id, day_calendar_id) VALUES(_trip_id, currval('calendar_id_seq'), _day_calendar_id);
            INSERT INTO calendar_element(calendar_id, start_date, end_date, positive) VALUES(currval('calendar_id_seq'), _date, _date, 1);
        ELSE
            SELECT CL.period_calendar_id INTO _calendar_id FROM calendar_link CL WHERE CL.trip_id = _trip_id;
            INSERT INTO calendar_element(calendar_id, start_date, end_date, positive) VALUES(_calendar_id, _date, _date, 1);
        END IF;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertRouteStopAndStopTime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean)
    RETURNS VOID AS $$
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
            IF _is_last IS FALSE THEN
                SELECT RE.id INTO _route_section_id FROM route_section RE WHERE start_stop_id = _stop_id AND end_stop_id = _related_stop_id;
                IF _is_first IS TRUE THEN
                    INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, route_section_id, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, _route_section_id, True, False, False) RETURNING id INTO _route_stop_id;
                ELSE
                    INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, route_section_id, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, _route_section_id, True, True, False) RETURNING id INTO _route_stop_id;
                END IF;
            ELSE
                SELECT RE.id INTO _route_section_id FROM route_section RE WHERE start_stop_id = _related_stop_id AND end_stop_id = _stop_id;
                INSERT INTO route_stop(route_id, waypoint_id, rank, scheduled_stop, route_section_id, pickup, drop_off, reservation_required) VALUES (_route_id, _stop_id, _rank, _scheduled, _route_section_id, False, True, False) RETURNING id INTO _route_stop_id;
            END IF;
        END IF;
        SELECT T.id INTO _trip_id FROM trip T JOIN trip_datasource TD ON TD.trip_id = T.id WHERE TD.code = _tcode AND T.route_id = _route_id; 
        INSERT INTO stop_time(route_stop_id, trip_id, departure_time, arrival_time) VALUES (_route_stop_id, _trip_id, _hour, _hour);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION CreateAdressType() 
    RETURNS VOID AS $$
    DECLARE
        _type_exists INTEGER;
    BEGIN
        SELECT INTO _type_exists (SELECT 1 FROM pg_type WHERE typname = 'adress');
        IF _type_exists IS NULL THEN
            CREATE TYPE adress AS (
                adress character varying,
                the_geom character varying,
                is_entrance boolean
            );
        END IF;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertPoi(_name varchar, _city_id integer, _type varchar, _priority integer, _datasource integer, _is_velo boolean, adresses adress[])
    RETURNS VOID AS $$
    DECLARE
        _type_id integer;
        _poi_id integer;
        _real_geom geometry(Point, 3943);
        _adress adress;
    BEGIN
        IF _is_velo THEN
            _type_id := _type::integer;
        ELSE
            SELECT id INTO _type_id FROM poi_type WHERE name = _type;
            IF _type_id IS NULL THEN
                INSERT INTO poi_type(name) VALUES(_type) RETURNING id INTO _type_id;
            END IF;
        END IF;
        INSERT INTO poi(name, city_id, poi_type_id, priority) VALUES (_name, _city_id, _type_id, _priority) RETURNING id INTO _poi_id;
        INSERT INTO poi_datasource(poi_id, code, datasource_id) VALUES (_poi_id, '', _datasource);
        FOREACH _adress IN ARRAY adresses
        LOOP
            _real_geom := ST_GeomFromText(_adress.the_geom, 3943);
            INSERT INTO poi_adress(poi_id, adress, is_entrance, the_geom) VALUES (_poi_id, _adress.adress, _adress.is_entrance, _real_geom);
        END LOOP;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION InsertRouteSection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date)
    RETURNS VOID AS $$
    DECLARE
        _real_geom geometry(Linestring, 3943);
    BEGIN
        _real_geom := ST_GeomFromText(_the_geom, 3943);
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION UpdateRouteSection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date)
    RETURNS VOID AS $$
    DECLARE
        _real_geom geometry(Linestring, 3943);
    BEGIN
        _real_geom := ST_GeomFromText(_the_geom, 3943);
        UPDATE route_section SET end_date = _end_date WHERE id = _route_section_id;
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION CleanPoi()
    RETURNS VOID AS $$
    BEGIN
        DELETE FROM poi_datasource;
        DELETE FROM poi_adress;
        DELETE FROM poi;
        DELETE FROM poi_type;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION CleanImport()
    RETURNS VOID AS $$
    BEGIN
        DELETE FROM route_datasource;
        DELETE FROM trip_datasource;
        DELETE FROM stop_time;
        DELETE FROM route_stop;
        DELETE FROM calendar_datasource;
        DELETE FROM calendar_link;
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
        INSERT INTO calendar(name, calendar_type) VALUES('Dimanche', 0);
    END;
    $$ LANGUAGE 'plpgsql';
