SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE OR REPLACE FUNCTION cleanimport() RETURNS void
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


CREATE OR REPLACE FUNCTION cleanpoi() RETURNS void
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


CREATE OR REPLACE FUNCTION insertcalendar(_name character varying, _ccode character varying, _datasource integer, _calendar_type calendar_type default 'periode') RETURNS integer 
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



CREATE TYPE date_pair AS (start_date date, end_date date);

-- _start_date, _end_date could be NULL (if no applicable dates)
-- previous_bounds could be also a NULL pair
CREATE OR REPLACE FUNCTION atomicdatecomputation (_start_date date, _end_date date, _operator calendar_operator, previous_bounds date_pair) RETURNS date_pair
	LANGUAGE plpgsql
	AS $$
	DECLARE
		_computed_date_pair date_pair;
	BEGIN
		-- RAISE DEBUG 'Operate this : (%,%) % (%,%)',previous_bounds.start_date,previous_bounds.end_date,_operator,_start_date,_end_date;		
		CASE _operator
			WHEN '+'::calendar_operator THEN -- Date muse be added
				IF _start_date IS NULL THEN
					-- We assume that if _start_date is NULL _end_date is also NULL
					_computed_date_pair := previous_bounds;
				ELSE
					IF previous_bounds.start_date IS NULL THEN
						_computed_date_pair.start_date := _start_date;
						_computed_date_pair.end_date := _end_date;
					ELSE
						IF _start_date < previous_bounds.start_date THEN
							_computed_date_pair.start_date := _start_date;
						ELSE
							_computed_date_pair.start_date := previous_bounds.start_date;
						END IF;						 
						IF _end_date > previous_bounds.end_date THEN
							_computed_date_pair.end_date := _end_date;
						ELSE
							_computed_date_pair.end_date := previous_bounds.end_date;
						END IF;
					END IF;
				END IF;
			WHEN '&'::calendar_operator THEN -- Must calculate intersection
				IF _start_date IS NULL THEN
					-- We assume that if _start_date is NULL _end_date is also NULL
					_computed_date_pair.start_date := NULL;
					_computed_date_pair.end_date := NULL;
				ELSE
					IF previous_bounds.start_date IS NULL THEN
						_computed_date_pair.start_date := NULL;
						_computed_date_pair.end_date := NULL;
					ELSE
						IF _start_date > previous_bounds.start_date THEN
							_computed_date_pair.start_date := _start_date;
						ELSE
							_computed_date_pair.start_date := previous_bounds.start_date;
						END IF;						 
						IF _end_date < previous_bounds.end_date THEN
							_computed_date_pair.end_date := _end_date;
						ELSE
							_computed_date_pair.end_date := previous_bounds.end_date;
						END IF;
						-- Check if intersect two distinct calendars
						IF _computed_date_pair.start_date > _computed_date_pair.end_date THEN
							_computed_date_pair.start_date := NULL;
							_computed_date_pair.end_date := NULL;							
						END IF;
					END IF;
				END IF;			
			WHEN '-'::calendar_operator THEN -- Date must be subs
				IF _start_date IS NULL OR previous_bounds.start_date IS NULL THEN
					-- Substract something NULL don't change object
					-- Substract something to a NULL object left him NULL
					_computed_date_pair := previous_bounds;
				ELSE
					IF _start_date <= previous_bounds.start_date THEN
						_computed_date_pair.start_date := _end_date + interval '1' day;
					ELSE
						_computed_date_pair.start_date := previous_bounds.start_date;
					END IF;						 
					IF _end_date >= previous_bounds.end_date THEN
						_computed_date_pair.end_date := _start_date - interval '1' day;
					ELSE
						_computed_date_pair.end_date := previous_bounds.end_date;
					END IF;
					-- If operation result is negative set it to NULL
					IF _computed_date_pair.start_date > _computed_date_pair.end_date THEN
						_computed_date_pair.start_date := NULL;
						_computed_date_pair.end_date := NULL;							
					END IF;
				END IF;
		END CASE;
		-- RAISE DEBUG 'Result (%,%)',_computed_date_pair.start_date,_computed_date_pair.end_date;
		RETURN _computed_date_pair;
	END;
	$$;
COMMENT ON FUNCTION atomicdatecomputation (_start_date date, date, calendar_operator, date_pair) IS 'Apply "operator" operation (with calendar element args) on a previous start/end couple. Result could be a pair of null if no date intersect or empty calendar';
	

-- If rank is null, we are in a calendar element deletion case
CREATE OR REPLACE FUNCTION computecalendarsstartend (_calendar_id integer, _start_date date, _end_date date, _rank integer, _operator calendar_operator, _currentElementDeletion boolean) RETURNS date_pair 
	LANGUAGE plpgsql
	AS $$
	DECLARE
		_cal record;
		_computed_date_pair date_pair;
		_cal_elt_rank_found boolean;
		_cal_elt_number integer;
		_rank_to_ignore integer;
	BEGIN
		-- RAISE DEBUG 'Calculate calendar %, _rank = %', _calendar_id, _rank;
		_cal_elt_rank_found := FALSE;
		_cal_elt_number := 0;
		_rank_to_ignore := 0; -- There is never rank = 0 (start at 1)
		-- If we want delete this element : don't take it into account for calculation
		IF _currentElementDeletion THEN
			_rank_to_ignore := _rank;
		END IF;
		BEGIN
			-- If there is not any calendar element in this calendar then we don't go in the loop.
			FOR _cal IN 
				SELECT id, operator, start_date, end_date, rank FROM calendar_element WHERE calendar_id = _calendar_id AND rank != _rank_to_ignore ORDER BY rank
			LOOP
				-- Note that we use start_date & end_date of a calendar element with an included calendar_id
				-- It is working only because we always duplicate computed_start_date/ computed_end_date of a calendar in all calendar element witch include it !
				-- RAISE DEBUG 'CalElt % : start = %, end = %, operator = %, rank = %', _cal.id, _cal.start_date, _cal.end_date, _cal.operator, _cal.rank;			
				-- First we need to remember the first date bounds
				IF _cal_elt_number = 0 THEN -- Must be true for _cal.rank = 1
					_computed_date_pair.start_date := _cal.start_date;
					_computed_date_pair.end_date := _cal.end_date;
				ELSE
					-- Second (_rank>1) we need to calculate new bounds
					IF _cal.rank = _rank THEN 				
						-- RAISE DEBUG 'This is the element of rank %', _cal.rank;
						_cal_elt_rank_found := TRUE;
						-- In that case we MUST use the new start/end dates (because the current one could be false until COMMIT)
						SELECT * FROM atomicdatecomputation(_start_date, _end_date, _operator,  _computed_date_pair) INTO _computed_date_pair;
					ELSE
						-- RAISE DEBUG 'Element of rank %', _cal.rank;
						SELECT * FROM atomicdatecomputation(_cal.start_date, _cal.end_date, _cal.operator, _computed_date_pair) INTO _computed_date_pair;
					END IF;
				END IF;
				_cal_elt_number := _cal_elt_number + 1;
			END LOOP;
			-- If we are on first recursion level, there is no cal_elt record with the provided rank (the one all that stuff must add)
			-- But we need to take it into account for finish computation
			IF NOT _cal_elt_rank_found AND NOT _currentElementDeletion THEN
				-- RAISE DEBUG 'Calendar element of rank % not found in calendar % (_cal_elt_number = %)', _rank, _calendar_id, _cal_elt_number;
				-- If _rank is null, current calendar element is being deleted.
				-- In that case the calculation (of the current calendar) is simply finished
				IF _rank IS NOT NULL THEN
					IF _cal_elt_number = 0 THEN
						-- RAISE DEBUG 'First calendar element ! We set date to (%, %)', _start_date, _end_date;
						IF _operator != '+'::calendar_operator THEN
							RAISE EXCEPTION 'First calendar_element must always have an operator + ';
						END IF;
						-- There is 0 elts in this calendar : calculation is trivial
						_computed_date_pair.start_date := _start_date;
						_computed_date_pair.end_date := _end_date;
					ELSE
						-- There is already calendar elements but the current one is new
						SELECT * FROM atomicdatecomputation(_start_date, _end_date, _operator, _computed_date_pair) INTO _computed_date_pair;
					END IF;
				END IF;
			END IF;
			UPDATE calendar SET computed_start_date = _computed_date_pair.start_date, computed_end_date = _computed_date_pair.end_date WHERE id = _calendar_id;
		EXCEPTION WHEN raise_exception THEN
			RAISE EXCEPTION '% %An atomic calendar operation failed for calendar %',SQLERRM , chr(10), _calendar_id;
		END;
		RETURN _computed_date_pair;		
	END;
    $$;
COMMENT ON FUNCTION computecalendarsstartend(integer, date, date, integer, calendar_operator, boolean) IS 'Calculate start/end computed dates of a calendar. Result could be a pair of null if no date intersect or empty calendar';
    

CREATE OR REPLACE FUNCTION propagateparentcalendarsstartend (_calendar_id integer, _rank integer, _currentElementDeletion boolean, _start_date date default null, _end_date date default null, _operator calendar_operator default null) RETURNS void 
    LANGUAGE plpgsql
    AS $$
    DECLARE
		_cal record;
		_computed_date_pair date_pair;
    BEGIN
		BEGIN
			-- Calculate new start/end computed date for current calendar
			SELECT * FROM computecalendarsstartend(_calendar_id, _start_date, _end_date, _rank, _operator, _currentElementDeletion) INTO _computed_date_pair;
			-- Launch same operation an all parent calendars (could have none)
			-- Infinite recursion must not happen because we previously check it with 'detectcalendarinclusionloop' function
			FOR _cal IN 
				SELECT calendar_id, rank, operator FROM calendar_element WHERE _calendar_id = included_calendar_id
			LOOP
				-- Need to update current calendar element with new calculated values
				UPDATE calendar_element SET start_date = _computed_date_pair.start_date, end_date = _computed_date_pair.end_date WHERE id = _cal.id;
				-- To calculate the parent calendar, we need to pass (not commited yet) new start/end date of updated calendar_element (and rand to found it)
				-- operator is passed because of the not already added calendar element (first call of this recursive function)
				-- We set currentElementDeletion, because just want to update fields, ignoring no calendar
				PERFORM propagateparentcalendarsstartend(_cal.calendar_id, _cal.rank, FALSE, _computed_date_pair.start_date, _computed_date_pair.end_date, _cal.operator);
			END LOOP;
		EXCEPTION WHEN raise_exception THEN
			RAISE EXCEPTION '% %Parent calendar element = %',SQLERRM , chr(10), _calendar_id;
		END;
    END;
    $$;
COMMENT ON FUNCTION propagateparentcalendarsstartend(integer, integer, boolean, date, date, calendar_operator) IS 'This recursive function launch computecalendarsstartend and call himself on an all parents calendar';



CREATE OR REPLACE FUNCTION insertcalendarelement(_calendar_id integer, _start_date date default NULL, _end_date date default NULL, _interval integer default 1, _operator calendar_operator default '+', _included_calendar_id integer default NULL) RETURNS integer 
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _id integer;
		_rank integer;
		_real_start_date date;
		_real_end_date date;
		_included_cal record;
    BEGIN		
		IF _included_calendar_id IS NOT NULL THEN
			-- Integrity control : a calendar element with an included_calendar_id could not have start_date & end_date provided
			IF _start_date IS NOT NULL OR _end_date IS NOT NULL THEN
				RAISE EXCEPTION 'A calendar element with an included_calendar_id could not have start_date & end_date provided !';
			END IF;			
			-- Abort creation if calendar creation will create an inclusion loop
			BEGIN
				PERFORM detectcalendarinclusionloop(_included_calendar_id, _calendar_id);
			EXCEPTION WHEN raise_exception THEN
				RAISE EXCEPTION '% %Cannot insert calendar. It will create an inclusion loop !',SQLERRM , chr(10);
			END;
			-- We need to extract start/end date from included calendar
			SELECT computed_start_date, computed_end_date, calendar_type FROM calendar WHERE id = _included_calendar_id INTO _included_cal;
			IF _included_cal.calendar_type = 'accessibilite'::calendar_type THEN
				RAISE EXCEPTION '"accessibilite" calendars cannot be included into any calendar !';
			END IF;
			-- Note that dates could be NULL
			_real_start_date := _included_cal.computed_start_date;
			_real_end_date := _included_cal.computed_end_date;
		ELSE
			IF _start_date IS NULL OR _end_date IS NULL THEN
				RAISE EXCEPTION 'You must provide start_date+end_date or included calendar !';
			END IF;
			_real_start_date := _start_date;
			_real_end_date := _end_date;
		END IF;
		-- At this point if _real_start_date or _real_end_date are null we know that there is an empty calendar underneath
		
		-- Second, calculate the rank of element
		SELECT count(*) FROM calendar_element WHERE calendar_id = _calendar_id INTO _rank;
		_rank := _rank + 1;
		
		-- RAISE DEBUG 'We insert a new element of rank %, date are (%, %)', _rank, _real_start_date, _real_end_date;
		-- Third, recalculate calendar start/end computed dates and recursively for all calendars that include this one
		BEGIN
			-- The new calendar_element is not already inserted so we need to pass information about it on sub routines
			PERFORM propagateparentcalendarsstartend(_calendar_id, _rank, FALSE, _real_start_date, _real_end_date, _operator);
		EXCEPTION WHEN raise_exception THEN
				RAISE EXCEPTION '% %Cannot insert calendar. It broke start stop rule somewhere !',SQLERRM , chr(10);
		END;
		-- Finally, we can commit transaction and insert calendar
        INSERT INTO calendar_element(calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES(_calendar_id, _rank, _real_start_date, _real_end_date, _operator, _interval, _included_calendar_id) RETURNING id INTO _id;
        RETURN _id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendarelement (integer, date, date, integer, calendar_operator, integer) IS 'Insert record in table calendar_element and return new id. Will RAISE if insertion cause start > end of a linked calendar. Trig a recalculation of parent calendars computed start stop date';



CREATE OR REPLACE FUNCTION deletecalendarelement(_calendar_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_rank integer;
		_new_rank integer;
		_cal_elt record;
    BEGIN
		-- Get rank of deleted element
		SELECT rank FROM calendar_element WHERE calendar_id = _calendar_id INTO _rank;
		-- Update calendars depending of the current one
        PERFORM propagateparentcalendarsstartend(_calendar_id,_rank,TRUE);
		-- Decrease rank of all element up to the current one
		FOR _cal_elt IN 
			SELECT id, rank FROM calendar_element WHERE calendar_id = _calendar_id AND rank > _rank
		LOOP
			_new_rank := _cal_elt.rank - 1;
			UPDATE calendar_element SET rank = _new_rank WHERE id = _cal_elt.id;
		END LOOP;
		-- Finally we delete the element
		DELETE FROM calendar_element WHERE id = _calendar_id;	
    END;
    $$;
COMMENT ON FUNCTION deletecalendarelement (integer) IS 'Delete record in table calendar_element. Trig a recalculation of parent calendars computed start stop date';



CREATE OR REPLACE FUNCTION detectcalendarinclusionloop (_included_calendar_id integer, _first_calendar_id integer) RETURNS void 
    LANGUAGE plpgsql
    AS $$
    DECLARE
	_cal record;
    BEGIN
		RAISE DEBUG 'LOOP cal = %', _included_calendar_id;
		-- Recursion stop condition : the loop is done
		IF _included_calendar_id = _first_calendar_id THEN
			RAISE EXCEPTION 'DETECT LOOP INCLUSION %--- Loop inclusion ---',chr(10);
		END IF;
		BEGIN
			-- Check all cal elt of the calendar of id "_included_calendar_id" 
			FOR _cal IN
				SELECT included_calendar_id AS id FROM calendar_element WHERE calendar_id = _included_calendar_id AND included_calendar_id IS NOT NULL
			LOOP
				PERFORM detectcalendarinclusionloop(_cal.id, _first_calendar_id);
			END LOOP;
		EXCEPTION WHEN raise_exception THEN			
			RAISE EXCEPTION '% %Parent calendar element = %',SQLERRM , chr(10), _included_calendar_id;
		END;
    END;
    $$;
COMMENT ON FUNCTION detectcalendarinclusionloop(integer, integer) IS 'This recursive function can detect loop inclusion. Will raise and trace calendar loop.';



CREATE OR REPLACE FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer,  _operator calendar_operator default '+') RETURNS void
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
			PERFORM insertcalendarelement(currval('calendar_id_seq'), _date, _date, _operator);
        ELSE
			PERFORM insertcalendarelement(_calendar_id, _date, _date, _operator);
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer, _operator calendar_operator) IS 'Insertion selon condition de nouvelles entrées calendar, calendar_datasource et calendar_element plus mise à jour dune entrée trip associée à ces nouveaux calendriers. Si le calendrier rattaché au trip existe déjà lors de lappel de cette fonction, elle effectuera une simple insertion dune entrée calendar_element.';

CREATE TYPE address AS (address character varying, the_geom character varying, is_entrance boolean);

CREATE OR REPLACE FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) RETURNS void
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


CREATE OR REPLACE FUNCTION insertroute(_lvid integer, _way character varying, _name character varying, _direction character varying, _code character varying, _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO route(line_version_id, way, name, direction) VALUES (_lvid, _way, _name, _direction);
        INSERT INTO route_datasource(route_id, datasource_id, code) VALUES (currval('route_id_seq'), _datasource, _code);
    END;
    $$;
COMMENT ON FUNCTION insertroute (integer, character varying, character varying, character varying, character varying, integer) IS 'Insert record in tables route and route_datasource.';


CREATE OR REPLACE FUNCTION insertroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date) RETURNS void
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


CREATE OR REPLACE FUNCTION insertroutestopandstoptime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean) RETURNS void
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

CREATE OR REPLACE FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _code character varying, _insee character varying, _datasource integer, _srid integer default 27572) RETURNS void
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


CREATE OR REPLACE FUNCTION insertstoparea(_city_id integer, _name character varying, _datasource integer) RETURNS void
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


CREATE OR REPLACE FUNCTION inserttrip(_name character varying, _tcode character varying, _rcode character varying, _lvid integer, _datasource integer) RETURNS void
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

CREATE OR REPLACE FUNCTION mergetrips(_trips integer[], _trip_calendar_id integer, _datasource_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _trip_parent_id integer;
    BEGIN
        -- create a new trip_parent using first trip in array
        INSERT INTO trip(name, route_id, trip_calendar_id) SELECT name || '_FH', route_id, _trip_calendar_id FROM trip WHERE id = _trips[1] RETURNING id INTO _trip_parent_id;
        INSERT INTO trip_datasource(trip_id, datasource_id, code) VALUES(_trip_parent_id, _datasource_id, 'FH');
        -- duplicate all stop_time linked to the first trip and link them to the new _trip_parent_id
        INSERT INTO stop_time(route_stop_id, trip_id, departure_time, arrival_time) SELECT route_stop_id, _trip_parent_id, departure_time, arrival_time FROM stop_time WHERE trip_id = _trips[1];
        -- update all _trips by linking them to the new _trip_parent_id and deleting their trip_calendar_id
        UPDATE trip SET(trip_calendar_id, trip_parent_id) = (NULL, _trip_parent_id) WHERE id = ANY(_trips);
    END;
    $$;
COMMENT ON FUNCTION mergetrips (_trips integer[], _trip_calendar_id integer, _datasource_id integer) IS 'Merge duplicated trips by creating a new one attached to a specific _trip_calendar_id. The trip_calendar days pattern is the sum of all patterns of each trip which will be merged.';


CREATE OR REPLACE FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) RETURNS void
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


CREATE OR REPLACE FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer,  _datasource integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _stop_id integer;
        _temp_geom character varying;
        _the_geom pgis.geometry(Point, 3943);
		_master_stop_id integer;
		_code character varying;
    BEGIN
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := pgis.ST_Transform(pgis.ST_GeomFromText(_temp_geom, 27572), 3943);
        UPDATE stop_history SET end_date = _date - interval '1 day' WHERE id = _stop_history_id RETURNING stop_id INTO _stop_id;
        INSERT INTO stop_history(stop_id, start_date, short_name, the_geom) VALUES (_stop_id, _date, _name, _the_geom);
		
		-- si master_stop_id est null, update l'accessibilite
		SELECT master_stop_id INTO _master_stop_id FROM stop WHERE id = _stop_id;
		IF _master_stop_id IS NULL THEN
			SELECT code INTO _code FROM stop_datasource
			WHERE datasource_id = _datasource
			AND stop_id = _stop_id;
			IF _code IS NOT NULL THEN		
				PERFORM setstopaccessibility(_stop_id, _access, _accessibility_mode_id, _code, _datasource);
			END IF;
		END IF;
    END;
    $$;
COMMENT ON FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer,  _datasource integer) IS 'La mise à jour dun stop est historisée. Cela implique la fermeture de la version courante dun stop_history en appliquant une date au champ end_date puis en la création de son successeur avec un champ end_date vide.';


CREATE OR REPLACE FUNCTION insertline(_number character varying, _physical_mode_id integer, _line_code character varying, _datasource integer, _priority integer default 0)
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


CREATE OR REPLACE FUNCTION insertlineversion(_line_id integer, _version integer, _start_date date, _end_date date, _planned_end_date date, _child_line_id integer, _name character varying, _forward_direction character varying, _backward_direction character varying, _bg_color character varying, _bg_hexa_color character varying, _fg_color character varying, _fg_hexa_color character varying, _carto_file text, _accessibility boolean, _air_conditioned boolean, _certified boolean, _comment text, _depot character varying, _datasource integer, _code character varying)
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


CREATE OR REPLACE FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer, _date date default null) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
		_accessibility_date date;
        _calendar_id integer;
		_calendar_element_id integer;
		_cal_elt record;
    BEGIN			
		IF _date IS NULL THEN
			_accessibility_date := current_date;
		ELSE
			_accessibility_date := _date;		
		END IF;

		-- inaccessibility calendar for the selected stop ?
		SELECT calendar_id INTO _calendar_id
		FROM accessibility_type a
		JOIN stop_accessibility s ON s.accessibility_type_id = a.id
		WHERE a.accessibility_mode_id = _accessibility_mode_id		
		AND s.stop_id = _stop_id;
		
		IF _calendar_id IS NOT NULL THEN
			-- inaccessibility for current date ?
			SELECT * INTO _cal_elt
			FROM calendar_element
			WHERE calendar_id = _calendar_id
			AND start_date <= _accessibility_date
			AND end_date > _accessibility_date;
			
			_calendar_element_id := _cal_elt.id;
		END IF;
		
		IF _access THEN
			IF _calendar_element_id IS NOT NULL THEN
				-- close inaccessibility for the current date 
				UPDATE calendar_element
				SET end_date = _accessibility_date
				WHERE id = _calendar_element_id;
				-- We just change the end_date : we must recalculate computed date of calendar
				PERFORM computecalendarsstartend (_calendar_id, _cal_elt.start_date, _accessibility_date, _cal_elt.rank, _cal_elt.operator, FALSE);
			END IF;
		ELSE
			IF _calendar_id IS NOT NULL THEN
				IF  _calendar_element_id IS NULL THEN
					PERFORM insertcalendarelement(_calendar_id, _accessibility_date, date '2999-12-31');
				END IF;
			ELSE
				SELECT insertcalendar('Access_'|| _accessibility_mode_id, _code, _datasource, 'accessibilite')  INTO _calendar_id;
				PERFORM insertcalendarelement(_calendar_id, _accessibility_date, date '2999-12-31');
				INSERT INTO accessibility_type(accessibility_mode_id, calendar_id) VALUES (_accessibility_mode_id, currval('calendar_id_seq'));
				INSERT INTO stop_accessibility(accessibility_type_id, stop_id) VALUES (currval('accessibility_type_id_seq'), _stop_id);			
			END IF;
		END IF;
    END;
    $$;
COMMENT ON FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer, _date date) IS 'Insert or update access(_access)  for an accessibility mode(_accessibility_mode_id) for the selected stop(_stop_id) and return the new stop_accessibility.id. _code is used,  if necessary, for the associated calendar.name ';


CREATE OR REPLACE FUNCTION stopisaccessible(_stop_id integer, _accessibility_mode_id integer, _date date default null)
    RETURNS boolean AS $$
    DECLARE
		_accessibility_date date;
        _master_stop_id integer;
		_calendar_id integer;
		_calendar_element_id integer;
		_result boolean;
    BEGIN
		IF _date IS NULL THEN
			_accessibility_date := current_date;
		ELSE
			_accessibility_date := _date;		
		END IF;
	
		-- phantom stop case => master_stop_id holds accessibility
		SELECT master_stop_id INTO _master_stop_id FROM stop WHERE id = _stop_id;
		IF _master_stop_id IS NOT NULL THEN
			SELECT stopisaccessible(_master_stop_id, _accessibility_mode_id, _date)  INTO _result;
			RETURN _result;
		END IF;
			
		SELECT calendar_id INTO _calendar_id
		FROM accessibility_type a
		JOIN stop_accessibility s ON s.accessibility_type_id = a.id
		WHERE a.accessibility_mode_id = _accessibility_mode_id
		AND s.stop_id = _stop_id;
		
		_result := true;
		IF _calendar_id IS NOT NULL THEN
			-- many calendar_elements ?
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

