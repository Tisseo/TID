SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1191 (class 1255 OID 199950)
-- Name: cleanimport(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cleanimport() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
    $$;
COMMENT ON FUNCTION cleanimport() IS 'Debug function used to clean all data related to import scripts from hastus/tigre.';
--
-- TOC entry 1181 (class 1255 OID 199951)
-- Name: cleanpoi(); Type: FUNCTION; Schema: public; Owner: postgres
--

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
COMMENT ON FUNCTION cleanpoi() IS 'Debug function used to clean all data related to poi.';
--
-- TOC entry 1180 (class 1255 OID 199952)
-- Name: createaddresstype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION createaddresstype() RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _type_exists INTEGER;
    BEGIN
        SELECT INTO _type_exists (SELECT 1 FROM pg_type WHERE typname = 'address');
        IF _type_exists IS NULL THEN
            CREATE TYPE address AS (
                address character varying,
                the_geom character varying,
                is_entrance boolean
            );
        END IF;
    END;
    $$;
COMMENT ON FUNCTION createaddresstype() IS 'Check address type exists and create it if needed.';


CREATE FUNCTION insertcalendar(_name character varying, _ccode character varying, _datasource integer, _calendar_type integer default 1) RETURNS integer 
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
COMMENT ON FUNCTION insertcalendar (character varying, character varying, integer, integer) IS 'insert record in tables calendar and calendar_datasource and return new calendar.id';

CREATE FUNCTION insertcalendarlink(_trip_id integer, _period_calendar_id integer, _day_calendar_id integer default NULL) RETURNS integer 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _id integer;
    BEGIN
        IF _day_calendar_id IS NULL THEN
            SELECT id INTO _day_calendar_id FROM calendar WHERE name = 'Dimanche';
        END IF;
        INSERT INTO calendar_link(trip_id, period_calendar_id, day_calendar_id) VALUES(_trip_id, _period_calendar_id, _day_calendar_id) RETURNING id INTO _id;
        RETURN _id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendarlink (integer, integer, integer) IS 'Insert record in table calendar_link(default value for day_calendar_id is Dimanche) and return new id';

CREATE FUNCTION insertcalendarelement(_calendar_id integer, _start_date date, _end_date date, _interval integer default NULL, _positive character varying default NULL, _included_calendar_id integer default NULL) RETURNS integer 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _id integer;
    BEGIN
        INSERT INTO calendar_element(calendar_id, start_date, end_date, positive, interval, included_calendar_id) VALUES(_calendar_id, _start_date, _end_date, _positive, _interval, _included_calendar_id) RETURNING id INTO _id;
        RETURN _id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendarelement (integer, date, date, integer, character varying, integer) IS 'Insert record in table calendar_element and return new id';

--
-- TOC entry 1192 (class 1255 OID 199953)
-- Name: insertcalendar(character varying, character varying, integer, character varying, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
    $$;
COMMENT ON FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer) IS 'Insert new records in tables calendar, calendar_element, calendar_datasource and calendar_link. If the calendar_link already exists, only insert a new record in table calendar_element. Provided codes are used to select trip and route ids using also the provided line version id.';
--
-- TOC entry 1190 (class 1255 OID 199954)
-- Name: insertpoi(character varying, integer, character varying, integer, integer, boolean, address[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _type_id integer;
        _poi_id integer;
        _real_geom geometry(Point, 3943);
        _address address;
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
        FOREACH _address IN ARRAY addresses
        LOOP
            _real_geom := ST_GeomFromText(_address.the_geom, 3943);
            INSERT INTO poi_address(poi_id, address, is_entrance, the_geom) VALUES (_poi_id, _address.address, _address.is_entrance, _real_geom);
        END LOOP;
    END;
    $$;
COMMENT ON FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) IS 'Insert a new couple of records in tables poi and poi_datasource, then insert related poi_address records if provided. The geometry provided is transformed from text to geometry(Point) using SRID fixed at 3943.';

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
        _real_geom geometry(Linestring, 3943);
    BEGIN
        _real_geom := ST_GeomFromText(_the_geom, 3943);
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$;
COMMENT ON FUNCTION insertroutesection (integer, integer, character varying, date) IS 'Insert record in table route_section.';

--
-- TOC entry 1186 (class 1255 OID 199957)
-- Name: insertroutestopandstoptime(character varying, character varying, character varying, character varying, integer, integer, boolean, integer, boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

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
    $$;
COMMENT ON FUNCTION insertroutestopandstoptime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean) IS 'Insert a new route_stop record if it doesn\'t exists then insert a related stop_time record. Using provided stop codes and position, attach the route_stop record to its related route_section and fill correct information about rank, pickup, dropoff fields. If the route_stop record already exists, only add a new related stop_time record.';

--
-- TOC entry 1189 (class 1255 OID 199958)
-- Name: insertstop(date, character varying, character varying, character varying, boolean, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _code character varying, _insee character varying, _datasource integer, _srid integer default 27572) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _stop_id integer;
        _stop_area_id integer;
        _the_geom geometry(Point, 3943);
        _temp_geom character varying;
    BEGIN
        SELECT SA.id INTO _stop_area_id FROM stop_area SA JOIN city C ON C.id = SA.city_id WHERE SA.short_name = _name AND C.insee = _insee;
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := ST_Transform(ST_GeomFromText(_temp_geom, _srid), 3943);

        IF _stop_area_id IS NULL THEN
            RAISE EXCEPTION 'stop area not found with this short_name % and city %', _name, _insee;
        ELSE
            INSERT INTO waypoint(id) VALUES (nextval('waypoint_id_seq')) RETURNING waypoint.id INTO _stop_id;
            INSERT INTO stop(id, stop_area_id) VALUES (_stop_id, _stop_area_id);
            INSERT INTO stop_datasource(stop_id, datasource_id, code) VALUES (_stop_id, _datasource, _code);
            INSERT INTO stop_history(stop_id, start_date, short_name, the_geom, accessibility) VALUES (_stop_id, _date, _name, _the_geom, _access);
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _code character varying, _insee character varying, _datasource integer, _srid integer) IS 'Insert a new record in table stop and its related data in tables waypoint, stop_datasource, stop_history. The geometry present in stop_history is provided as x,y values and is transformed into a geometry(Point) using a specific SRID.';

--
-- TOC entry 1187 (class 1255 OID 199959)
-- Name: insertstoparea(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

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
COMMENT ON FUNCTION insertstoparea (integer, character varying, integer) IS 'Insert record in tables stop_area and stop_area_datasource';
--
-- TOC entry 1184 (class 1255 OID 199960)
-- Name: inserttrip(character varying, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

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
COMMENT ON FUNCTION inserttrip (character varying, character varying, character varying, integer, integer) IS 'Insert record in tables trip and trip_datasource, route is found from the route code(datasource) _rcode and the line_version id _lvid';

--
-- TOC entry 1185 (class 1255 OID 199961)
-- Name: updateroutesection(integer, integer, character varying, date, integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _real_geom geometry(Linestring, 3943);
    BEGIN
        _real_geom := ST_GeomFromText(_the_geom, 3943);
        UPDATE route_section SET end_date = _end_date WHERE id = _route_section_id;
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom);
    END;
    $$;
COMMENT ON FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) IS 'Close a route_section by updating the existing record and fixing its end date. Then insert a new route_section which will replace the old one, with an empty end date.';

--
-- TOC entry 1183 (class 1255 OID 199962)
-- Name: updatestop(integer, date, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
    $$;
COMMENT ON FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean) IS 'Close an old stop_history version by setting its end date, then add a new version of this stop_history. The provided geometry is passed as x, y values and is transformed into a geometry(Point) switching SRID from 27572 to 3943.';

--
-- Name: insertline(character varying, integer,  character varying,  integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public.insertline(_number character varying, _physical_mode_id integer, _line_code character varying, _datasource integer, _priority integer default 0)
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

--
-- Name: insertlineversion(integer, integer, date, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text, boolean, boolean, boolean, text, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public.insertlineversion(_line_id integer, _version integer, _start_date date, _end_date date, _planned_end_date date, _child_line_id integer, _name character varying, _forward_direction character varying, _backward_direction character varying, _bg_color character varying, _bg_hexa_color character varying, _fg_color character varying, _fg_hexa_color character varying, _carto_file text, _accessibility boolean, _air_conditioned boolean, _certified boolean, _comment text, _depot character varying, _datasource integer, _code character varying)
    RETURNS integer AS $$
    DECLARE
        _line_version_id integer;
    BEGIN
        INSERT INTO line_version (line_id, version, start_date, end_date, planned_end_date, child_line_id, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, carto_file, accessibility, air_conditioned, certified, comment, depot) VALUES (_line_id, _version, _start_date, _end_date, _planned_end_date, _child_line_id, _name, _forward_direction, _backward_direction, _bg_color, _bg_hexa_color, _fg_color, _fg_hexa_color, _carto_file, _accessibility, _air_conditioned, _certified, _comment, _depot) RETURNING line_version.id INTO _line_version_id;
        INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (_line_version_id, _datasource, _code);
        RETURN _line_version_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertlineversion (integer, integer, date, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text, boolean, boolean, boolean, text, character varying, integer, character varying) IS 'Insert record in tables line_version and line_version_datasource and return the new line_version.id';





