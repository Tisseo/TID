SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog, pgis;

CREATE TYPE date_pair AS (start_date date, end_date date, bit_mask bit varying, mask_length smallint);

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
        DELETE FROM poi_stop;
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

-- This could take a while because of recursion
CREATE OR REPLACE FUNCTION recalculateallcalendars() RETURNS void
LANGUAGE plpgsql
	AS $$
	DECLARE
		_cal record;
		_computed_date_pair date_pair;
	BEGIN
		-- First, "include" calendar elements with calculated _end_date
		UPDATE calendar_element SET end_date = NULL, start_date = NULL WHERE included_calendar_id IS NOT NULL;
		-- Two, vacuum computed dates
		UPDATE calendar SET computed_start_date = NULL, computed_end_date = NULL;
		-- This could take a while because of recursion
		FOR _cal IN
			SELECT id FROM calendar
		LOOP
			-- Recalculate computed date for given calendar
			-- Pass TRUE to deletion to force computecalendarsstartend to accept NULL for given calendar_element attributes
			--¨Pass TRUE to _recalculate_included_calendar to force recalculate sub calendars
			SELECT * FROM computecalendarsstartend(_cal.id, NULL, NULL, NULL, NULL, TRUE, NULL, TRUE) INTO _computed_date_pair;
		END LOOP;
	END;
	$$;
COMMENT ON FUNCTION recalculateallcalendars () IS 'Recalculate all calendar computed fields, and "include" calendar element start/end';


CREATE OR REPLACE FUNCTION updatecalendarlimit() RETURNS void
LANGUAGE plpgsql
	AS $$
	DECLARE
		_cal record;
		_computed_date_pair date_pair;
		current_limit date;
		new_limit date;
	BEGIN
		SELECT value FROM global_vars WHERE name = 'maximum_calendar_date' INTO current_limit;

		new_limit := current_limit + interval '1' year;

		UPDATE global_vars SET value = new_limit WHERE name = 'maximum_calendar_date';

		-- Update "simple" calendar elements with hard coded _end_date
		UPDATE calendar_element SET end_date = new_limit WHERE end_date = current_limit and included_calendar_id IS NULL;
		PERFORM recalculateallcalendars();
	END;
	$$;
COMMENT ON FUNCTION updatecalendarlimit () IS 'Update date limit. Eg. from 2020-12-31 to 2021-12-31. Call this function every year.';


CREATE OR REPLACE FUNCTION applybitmask(_source_bit_mask bit varying, _new_bit_mask bit varying, _bounds_start_date date, _bounds_end_date date, _operator calendar_operator) RETURNS bit varying
LANGUAGE plpgsql
	AS $$
	DECLARE
		_resulting_bit_mask bit varying;
	BEGIN
		CASE _operator
			WHEN '+'::calendar_operator THEN -- Date muse be added
				_resulting_bit_mask := _source_bit_mask | _new_bit_mask;
			WHEN '&'::calendar_operator THEN -- Must calculate intersection
				_resulting_bit_mask := _source_bit_mask & _new_bit_mask;
			WHEN '-'::calendar_operator THEN -- Date must be subs
				_resulting_bit_mask := _source_bit_mask & (~_new_bit_mask);
		END CASE;
		RETURN _resulting_bit_mask;
	END;
	$$;
COMMENT ON FUNCTION applybitmask (bit varying, bit varying, date, date, calendar_operator) IS 'Return resulting bitmask applying new bitmask on previous bitmask according to operator';


CREATE OR REPLACE FUNCTION getcalendarelementbitmask (_start_date date, _end_date date, _mask_length integer, _cal_included_calendar_id integer, _cal_start_date date, _cal_end_date date, _cal_interval integer) RETURNS bit varying
LANGUAGE plpgsql
	AS $$
	DECLARE
		_bit_mask bit varying;
		_bit_mask_text text;
		_tmp_text text;
		_start_diff integer;
		_end_diff integer;
		_cal_lenght integer;
		_cal_displayed_lenght integer;
		_iterator integer;
		_interval_counter integer;
	BEGIN
		-- RAISE DEBUG 'mask bounds = (%,%) , cal = (%,%)',_start_date,_end_date,_cal_start_date,_cal_end_date;
		-- Ignore out of bounds masks
		IF _end_date >= _cal_start_date AND _start_date <= _cal_end_date THEN
			IF _cal_included_calendar_id IS NOT NULL THEN
				_bit_mask := getcalendarbitmask(_cal_included_calendar_id, _start_date, _end_date);
			ELSE
				_start_diff := _cal_start_date - _start_date;
				_end_diff := _end_date - _cal_end_date;
				_cal_lenght := _cal_end_date - _cal_start_date + 1;
				-- RAISE DEBUG 'start_diff = %, end_diff = % , cal_lenght = %, _cal_interval = %',_start_diff,_end_diff,_cal_lenght,_cal_interval;
				IF _start_diff >= 0 THEN
					-- In this case _cal_start_date will be the first active date (and we need to fill left with 0)
					IF _end_diff > 0 THEN
						-- In this case _cal_end_date will be the last active date (and we need to fill right with 0)
						_bit_mask_text := lpad('0',_end_diff,'0');
						IF _cal_interval > 1 THEN
							_iterator := 0;
							_interval_counter := _cal_interval;
							_tmp_text := '';
							WHILE _iterator < _cal_lenght
							LOOP
								IF _interval_counter = _cal_interval THEN
									_tmp_text := _tmp_text || '1';
									_interval_counter := 0;
								ELSE
									_tmp_text := _tmp_text || '0';
								END IF;
								_interval_counter := _interval_counter + 1;
								_iterator := _iterator + 1;
								-- RAISE DEBUG 'tmp_text = %',_tmp_text;
							END LOOP;
							_bit_mask_text := _tmp_text || _bit_mask_text;
						ELSE
							_bit_mask_text := lpad(_bit_mask_text,_cal_lenght + _end_diff,'1');
						END IF;
						_bit_mask_text := lpad(_bit_mask_text, _mask_length,'0');
					ELSE
						-- In this case we trunk cal mask before the end
						IF _cal_interval > 1 THEN
							_iterator := 0;
							_interval_counter := _cal_interval;
							_bit_mask_text := '';
							_cal_displayed_lenght := _cal_lenght + _end_diff;
							WHILE _iterator < _cal_displayed_lenght
							LOOP
								IF _interval_counter = _cal_interval THEN
									_bit_mask_text := _bit_mask_text || '1';
									_interval_counter := 0;
								ELSE
									_bit_mask_text := _bit_mask_text || '0';
								END IF;
								_interval_counter := _interval_counter + 1;
								_iterator := _iterator + 1;
							END LOOP;
						ELSE
							_bit_mask_text := lpad('1',_cal_lenght + _end_diff,'1');
						END IF;
						_bit_mask_text := lpad(_bit_mask_text, _mask_length,'0');
					END IF;
				ELSE
					-- In this case we need to calculate first active day with a modulo
					IF _end_diff > 0 THEN
						-- In this case we will need to set some 0 at the end
						_bit_mask_text := lpad('0', _end_diff,'0');
						IF _cal_interval > 1 THEN
							_iterator := 0;
							_interval_counter := (_start_date - _cal_start_date)%_cal_interval;
							IF _interval_counter = 0 THEN
								_interval_counter := _cal_interval;
							END IF;
							_tmp_text := '';
							_cal_displayed_lenght := _cal_lenght - _end_diff;
							-- RAISE DEBUG '_cal_displayed_lenght = %, _interval_counter = %',_cal_displayed_lenght, _interval_counter;
							WHILE _iterator < _cal_displayed_lenght
							LOOP
								IF _interval_counter = _cal_interval THEN
									_tmp_text := _tmp_text || '1';
									_interval_counter := 0;
								ELSE
									_tmp_text := _tmp_text || '0';
								END IF;
								_interval_counter := _interval_counter + 1;
								_iterator := _iterator + 1;
							END LOOP;
							_bit_mask_text := _tmp_text || _bit_mask_text;
						ELSE
							_bit_mask_text := lpad(_bit_mask_text,_mask_length,'1');
						END IF;
					ELSE
						IF _cal_interval > 1 THEN
							_iterator := 0;
							_interval_counter := (_start_date - _cal_start_date)%_cal_interval;
							IF _interval_counter = 0 THEN
								_interval_counter := _cal_interval;
							END IF;
							_bit_mask_text := '';
							_cal_displayed_lenght := _cal_lenght + _end_diff + _start_diff;
							-- RAISE DEBUG '2 _cal_displayed_lenght = %, _interval_counter = %',_cal_displayed_lenght, _interval_counter;
							WHILE _iterator < _cal_displayed_lenght
							LOOP
								IF _interval_counter = _cal_interval THEN
									_bit_mask_text := _bit_mask_text || '1';
									_interval_counter := 0;
								ELSE
									_bit_mask_text := _bit_mask_text || '0';
								END IF;
								_interval_counter := _interval_counter + 1;
								_iterator := _iterator + 1;
							END LOOP;
						ELSE
							_bit_mask_text := lpad('1',_mask_length,'1');
						END IF;
					END IF;
				END IF;
				_bit_mask := (_bit_mask_text)::bit varying;
			END IF;
		ELSE
			_bit_mask := lpad('0', _mask_length,'0')::bit varying;
		END IF;
		-- RAISE DEBUG '_bit_mask = %',_bit_mask;
		RETURN _bit_mask;
	END;
	$$;
COMMENT ON FUNCTION getcalendarelementbitmask (date, date, integer, integer, date, date, integer) IS 'Return active days calendar element bitmask between provided dates bounds';

CREATE OR REPLACE FUNCTION getcalendarbitmask (_calendar_id integer, _start_date date, _end_date date) RETURNS bit varying
LANGUAGE plpgsql
	AS $$
	DECLARE
		_cumuled_bit_mask bit varying;
		_new_bit_mask bit varying;
		_mask_length integer;
		_cal_elt record;
	BEGIN
		-- First create a 0000000... mask
		_mask_length := (_end_date - _start_date )+ 1;
		_cumuled_bit_mask := lpad('0', _mask_length,'0')::bit varying;
		-- RAISE DEBUG 'mask length is %', _mask_length;

		FOR _cal_elt IN
			SELECT * FROM calendar_element WHERE calendar_id = _calendar_id ORDER BY rank
		LOOP
			_new_bit_mask := getcalendarelementbitmask(_start_date, _end_date, _mask_length, _cal_elt.included_calendar_id, _cal_elt.start_date, _cal_elt.end_date, _cal_elt.interval);
			select applybitmask(_cumuled_bit_mask, _new_bit_mask, _start_date, _end_date, _cal_elt.operator) INTO _cumuled_bit_mask;
		END LOOP;

		RETURN _cumuled_bit_mask;
	END;
	$$;
COMMENT ON FUNCTION getcalendarbitmask (integer, date, date) IS 'Return active days calendar bitmask between provided dates bounds. You suppose to pass and end_date > start_date : I do not check for it';


CREATE OR REPLACE FUNCTION getbitmaskbeetweencalendars (_first_calendar_id integer, _second_calendar_id integer, _start_date date, _end_date date, _operator calendar_operator default '&') RETURNS bit varying
LANGUAGE plpgsql
	AS $$
	DECLARE
		_bit_mask bit varying;
		_first_cal_bit_mask bit varying;
		_second_cal_bit_mask bit varying;
	BEGIN
		_first_cal_bit_mask := getcalendarbitmask(_first_calendar_id,_start_date,_end_date);
		_second_cal_bit_mask := getcalendarbitmask(_second_calendar_id,_start_date,_end_date);
		select applybitmask(_first_cal_bit_mask, _second_cal_bit_mask, _start_date, _end_date, _operator) INTO _bit_mask;
		RETURN _bit_mask;
	END;
	$$;
COMMENT ON FUNCTION getbitmaskbeetweencalendars (integer, integer, date, date, calendar_operator) IS 'Return (first_calendar (operator) second_calendar)  bitmask between provided dates bounds. You suppose to pass and end_date > start_date : I do not check for it';


CREATE OR REPLACE FUNCTION getdateboundsbeetweencalendars (_first_calendar_id integer, _second_calendar_id integer, _operator calendar_operator default '&') RETURNS date_pair
LANGUAGE plpgsql
	AS $$
	DECLARE
		_bit_mask bit varying;
		_first_cal_bit_mask bit varying;
		_second_cal_bit_mask bit varying;
		first_bounds record;
		second_bounds record;
		min_start_date date;
		max_end_date date;
		_computed_date_pair date_pair;
	BEGIN
	    -- First get full bitmask of the two calendars and min/max date
        SELECT computed_start_date, computed_end_date FROM calendar WHERE id = _first_calendar_id INTO first_bounds;
        SELECT computed_start_date, computed_end_date FROM calendar WHERE id = _second_calendar_id INTO second_bounds;
		IF(first_bounds.computed_start_date < second_bounds.computed_start_date) THEN
		    min_start_date := first_bounds.computed_start_date;
		ELSE
		    min_start_date := second_bounds.computed_start_date;
		END IF;
		IF(first_bounds.computed_end_date > second_bounds.computed_end_date) THEN
		    max_end_date := first_bounds.computed_end_date;
		ELSE
		    max_end_date := second_bounds.computed_end_date;
		END IF;
        _first_cal_bit_mask := getcalendarbitmask(_first_calendar_id, min_start_date, max_end_date);
	    _second_cal_bit_mask := getcalendarbitmask(_second_calendar_id, min_start_date, max_end_date);
		-- Second get the resulted bitmask
	    SELECT applybitmask(_first_cal_bit_mask, _second_cal_bit_mask, min_start_date, max_end_date, _operator) INTO _bit_mask;
		-- Third get the bound of resulted bitmask
        SELECT * FROM detectmaskbounds(_bit_mask, min_start_date, ((max_end_date - min_start_date) + 1)::smallint) into _computed_date_pair;
	    RETURN _computed_date_pair;
	END;
	$$;
COMMENT ON FUNCTION getdateboundsbeetweencalendars (integer, integer, calendar_operator) IS 'Return (first_calendar (operator) second_calendar) date bounds. You suppose to pass and end_date > start_date : I do not check for it';



CREATE OR REPLACE FUNCTION updateordeletecalendar (_calendar_id integer, _start_date date, _end_date date) RETURNS void
LANGUAGE plpgsql
	AS $$
	DECLARE
		_bit_mask bit varying;
		_cal_elt record;
		_id integer;
	BEGIN
		SELECT id FROM calendar_element WHERE included_calendar_id = _calendar_id INTO _id;
		IF FOUND THEN
			RAISE EXCEPTION 'You cannot delete or update a calendar %, it is included by some calendar elements', _calendar_id;
		END IF;
		_bit_mask := getcalendarbitmask(_calendar_id,_start_date,_end_date);
		IF (_bit_mask::text ~ '^0+$') THEN
			FOR _cal_elt IN
				SELECT * FROM calendar_element WHERE calendar_id = _calendar_id ORDER BY rank DESC
			LOOP
				PERFORM deletecalendarelement(_cal_elt.id);
			END LOOP;
			UPDATE trip SET period_calendar_id = NULL WHERE period_calendar_id = _calendar_id;
			DELETE FROM calendar_datasource WHERE calendar_id = _calendar_id;
			DELETE FROM calendar WHERE id = _calendar_id;
		ELSE
			PERFORM insertcalendarelement(_calendar_id, _start_date, _end_date, 1, '&');
		END IF;
	END;
	$$;
COMMENT ON FUNCTION updateordeletecalendar (integer, date, date) IS 'Check if a calendar does have active dates beetween two dates. If yes then add a union calendar element which restrict dates beetween given dates else delete calendar.';

CREATE OR REPLACE FUNCTION detectmaskbounds (_bit_mask bit varying, _start_date date, _bit_mask_lenght smallint) RETURNS date_pair
LANGUAGE plpgsql
	AS $$
	DECLARE
		_computed_date_pair date_pair;
		_iterator integer;
		_first_active_bit_index integer;
		_last_active_bit_index integer;
		_bit_mask_text text;
		_segment_bit_mask text;
	BEGIN
		-- RAISE DEBUG 'detectmaskbounds : _tmp_bitmask % _start_bitmask_date % _bit_mask_lenght %',_tmp_bitmask, _start_bitmask_date, _bit_mask_lenght;
		_iterator := 0;
		_first_active_bit_index := -1;
		_last_active_bit_index := 0;
		_bit_mask_text := '';
		_segment_bit_mask := '';
		WHILE _iterator < _bit_mask_lenght
		LOOP
			IF get_bit(_bit_mask, _iterator) = 1 THEN
				_last_active_bit_index := _iterator;
				IF _first_active_bit_index = -1 THEN -- This is the first 1
					_first_active_bit_index := _iterator;
					_bit_mask_text := '1';
				ELSE
					_bit_mask_text := _bit_mask_text || _segment_bit_mask || '1';
				END IF;
				_segment_bit_mask := '';
			ELSE -- current mask value is 0
				IF _first_active_bit_index != -1 THEN
					_segment_bit_mask := _segment_bit_mask || '0';
				END IF;
			END IF;
			_iterator := _iterator + 1;
		END LOOP;
		IF _first_active_bit_index = -1 THEN -- There is only zeros
			_computed_date_pair.start_date := NULL;
			_computed_date_pair.end_date := NULL;
			_computed_date_pair.bit_mask := NULL;
			_computed_date_pair.mask_length := 0;
		ELSE
			_computed_date_pair.start_date := _start_date + cast ((_first_active_bit_index) || 'day' as interval);
			_computed_date_pair.end_date := _start_date + cast ((_last_active_bit_index) || 'day' as interval);
			_computed_date_pair.mask_length := _last_active_bit_index -_first_active_bit_index + 1;
			_computed_date_pair.bit_mask := (_bit_mask_text)::bit varying;
		END IF;
		RETURN _computed_date_pair;
	END;
	$$;
COMMENT ON FUNCTION detectmaskbounds (bit varying, date, smallint) IS 'Return full date_pair (start date, end date, adjusted bitmask and length) for a given bitmask and start date. The returned bitmask will be probably different from the given one.';

-- _start_date, _end_date could be NULL (if no applicable dates)
-- previous_bounds could be also a NULL pair
CREATE OR REPLACE FUNCTION atomicdatecomputation (_start_date date, _end_date date, _bit_mask bit varying, _bit_mask_lenght smallint, _operator calendar_operator, previous_bounds date_pair) RETURNS date_pair
	LANGUAGE plpgsql
	AS $$
	DECLARE
		_computed_date_pair date_pair;
		_tmp_bitmask bit varying;
		_start_bitmask_date date;
		_end_bitmask_date date;
		_effective_start_bitmask_date date;
		_effective_end_bitmask_date date;
		_previous_bit_mask_trimed bit varying;
		_new_bit_mask_trimed bit varying;
	BEGIN
		-- RAISE DEBUG 'Operate this : (%,%) % (%,%)',previous_bounds.start_date,previous_bounds.end_date,_operator,_start_date,_end_date;
		-- RAISE DEBUG '_bit_mask : "%"  previous_bounds.bit_mask: "%"',_bit_mask, previous_bounds.bit_mask;
		CASE _operator
			WHEN '+'::calendar_operator THEN -- Date muse be added
				IF _start_date IS NULL THEN
					-- We assume that if _start_date is NULL _end_date is also NULL
					_computed_date_pair := previous_bounds;
				ELSE
					IF previous_bounds.start_date IS NULL THEN
						_computed_date_pair.start_date := _start_date;
						_computed_date_pair.end_date := _end_date;
						_computed_date_pair.bit_mask := _bit_mask;
						_computed_date_pair.mask_length := _bit_mask_lenght;
					ELSE
						IF _start_date < previous_bounds.start_date THEN
							_start_bitmask_date := _start_date;
							_tmp_bitmask := (lpad('',previous_bounds.start_date - _start_bitmask_date,'0'))::bit varying;
							_previous_bit_mask_trimed := _tmp_bitmask || previous_bounds.bit_mask;
							_new_bit_mask_trimed := _bit_mask;
						ELSE
							_start_bitmask_date := previous_bounds.start_date;
							_tmp_bitmask := (lpad('',_start_date - _start_bitmask_date,'0'))::bit varying;
							_new_bit_mask_trimed := _tmp_bitmask || _bit_mask;
							_previous_bit_mask_trimed := previous_bounds.bit_mask;
						END IF;
						IF _end_date > previous_bounds.end_date THEN
							_end_bitmask_date := _end_date;
							_tmp_bitmask := (lpad('',_end_bitmask_date - previous_bounds.end_date,'0'))::bit varying;
							_previous_bit_mask_trimed := _previous_bit_mask_trimed || _tmp_bitmask;
						ELSE
							_end_bitmask_date := previous_bounds.end_date;
							_tmp_bitmask := (lpad('',_end_bitmask_date - _end_date,'0'))::bit varying;
							_new_bit_mask_trimed := _new_bit_mask_trimed || _tmp_bitmask;
						END IF;
						-- RAISE DEBUG '_new_bit_mask_trimed : "%"  _previous_bit_mask_trimed: "%", _start_bitmask_date = % _end_bitmask_date = %',_new_bit_mask_trimed,_previous_bit_mask_trimed, _start_bitmask_date,_end_bitmask_date;
						select applybitmask(_previous_bit_mask_trimed, _new_bit_mask_trimed, _start_bitmask_date, _end_bitmask_date, _operator) INTO _tmp_bitmask;
						select * FROM detectmaskbounds(_tmp_bitmask, _start_bitmask_date, ((_end_bitmask_date - _start_bitmask_date) + 1)::smallint) into _computed_date_pair;
					END IF;
				END IF;
			WHEN '&'::calendar_operator THEN -- Must calculate intersection
				IF _start_date IS NULL THEN
					-- We assume that if _start_date is NULL _end_date is also NULL
					_computed_date_pair.start_date := NULL;
					_computed_date_pair.end_date := NULL;
					_computed_date_pair.bit_mask := NULL;
					_computed_date_pair.mask_length := 0;
				ELSE
					IF previous_bounds.start_date IS NULL THEN
						_computed_date_pair.start_date := NULL;
						_computed_date_pair.end_date := NULL;
						_computed_date_pair.bit_mask := NULL;
						_computed_date_pair.mask_length := 0;
					ELSE
						IF _start_date < previous_bounds.start_date THEN
							_effective_start_bitmask_date := previous_bounds.start_date;
							_start_bitmask_date := _start_date;
							_tmp_bitmask := (lpad('',previous_bounds.start_date - _start_bitmask_date,'0'))::bit varying;
							_previous_bit_mask_trimed := _tmp_bitmask || previous_bounds.bit_mask;
							_new_bit_mask_trimed := _bit_mask;
						ELSE
							_effective_start_bitmask_date := _start_date;
							_start_bitmask_date := previous_bounds.start_date;
							_tmp_bitmask := (lpad('',_start_date - _start_bitmask_date,'0'))::bit varying;
							_new_bit_mask_trimed := _tmp_bitmask || _bit_mask;
							_previous_bit_mask_trimed := previous_bounds.bit_mask;
						END IF;
						IF _end_date > previous_bounds.end_date THEN
							_effective_end_bitmask_date := previous_bounds.end_date;
							_end_bitmask_date := _end_date;
							_tmp_bitmask := (lpad('',_end_bitmask_date - previous_bounds.end_date,'0'))::bit varying;
							_previous_bit_mask_trimed :=  _previous_bit_mask_trimed || _tmp_bitmask;
						ELSE
							_effective_end_bitmask_date := _end_date;
							_end_bitmask_date := previous_bounds.end_date;
							_tmp_bitmask := (lpad('',_end_bitmask_date - _end_date,'0'))::bit varying;
							_new_bit_mask_trimed := _new_bit_mask_trimed || _tmp_bitmask;
						END IF;
						-- Check if intersect two distinct calendars
						IF _effective_start_bitmask_date > _effective_end_bitmask_date THEN
							_computed_date_pair.start_date := NULL;
							_computed_date_pair.end_date := NULL;
							_computed_date_pair.bit_mask := NULL;
							_computed_date_pair.mask_length := 0;
						ELSE
							select applybitmask(_previous_bit_mask_trimed, _new_bit_mask_trimed, _start_bitmask_date, _end_bitmask_date, _operator) INTO _tmp_bitmask;
							select * FROM detectmaskbounds(_tmp_bitmask, _start_bitmask_date, ((_end_bitmask_date - _start_bitmask_date) + 1)::smallint) into _computed_date_pair;
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
						_effective_start_bitmask_date := _end_date + interval '1' day;
						_start_bitmask_date := _start_date;
						_tmp_bitmask := (lpad('',previous_bounds.start_date - _start_bitmask_date,'0'))::bit varying;
						_previous_bit_mask_trimed := _tmp_bitmask || previous_bounds.bit_mask;
						_new_bit_mask_trimed := _bit_mask;
					ELSE
						_effective_start_bitmask_date := previous_bounds.start_date;
						_start_bitmask_date := previous_bounds.start_date;
						_tmp_bitmask := (lpad('',_start_date - _start_bitmask_date,'0'))::bit varying;
						_new_bit_mask_trimed := _tmp_bitmask || _bit_mask;
						_previous_bit_mask_trimed := previous_bounds.bit_mask;
					END IF;
					IF _end_date >= previous_bounds.end_date THEN
						_effective_end_bitmask_date := _start_date - interval '1' day;
						_end_bitmask_date := _end_date;
						_tmp_bitmask := (lpad('',_end_bitmask_date - previous_bounds.end_date,'0'))::bit varying;
						_previous_bit_mask_trimed := _previous_bit_mask_trimed || _tmp_bitmask;
					ELSE
						_effective_end_bitmask_date := previous_bounds.end_date;
						_end_bitmask_date := previous_bounds.end_date;
						_tmp_bitmask := (lpad('',_end_bitmask_date - _end_date,'0'))::bit varying;
						_new_bit_mask_trimed := _new_bit_mask_trimed || _tmp_bitmask;
					END IF;
					-- If operation result is negative set it to NULL
					IF _effective_start_bitmask_date > _effective_end_bitmask_date THEN
						_computed_date_pair.start_date := NULL;
						_computed_date_pair.end_date := NULL;
						_computed_date_pair.bit_mask := NULL;
						_computed_date_pair.mask_length := 0;
					ELSE
						select applybitmask(_previous_bit_mask_trimed, _new_bit_mask_trimed, _start_bitmask_date, _end_bitmask_date, _operator) INTO _tmp_bitmask;
						select * FROM detectmaskbounds(_tmp_bitmask, _start_bitmask_date, ((_end_bitmask_date - _start_bitmask_date) + 1)::smallint) into _computed_date_pair;
					END IF;
				END IF;
		END CASE;
		-- RAISE DEBUG 'Result (%,%)',_computed_date_pair.start_date,_computed_date_pair.end_date;
		RETURN _computed_date_pair;
	END;
	$$;
COMMENT ON FUNCTION atomicdatecomputation (date, date, bit varying, smallint, calendar_operator, date_pair) IS 'Apply "operator" operation (with calendar element args) on a previous start/end couple. Result could be a pair of null if no date intersect or empty calendar';

-- If _bit_mask is given, ignore interval
-- If rank is null, we are in a calendar element deletion case
CREATE OR REPLACE FUNCTION computecalendarsstartend (_calendar_id integer, _start_date date, _end_date date, _rank integer, _operator calendar_operator, _currentElementDeletion boolean, _bit_mask bit varying, _recalculate_included_calendar boolean default FALSE) RETURNS date_pair
	LANGUAGE plpgsql
	AS $$
	DECLARE
		_cal record;
		_computed_date_pair date_pair;
		_recalculated_date_pair date_pair;
		_cal_elt_rank_found boolean;
		_cal_elt_number integer;
		_rank_to_ignore integer;
		-- TODO : delete this when cache mecanism ready
		_cal_bit_mask bit varying;
		_cal_mask_lenght smallint;
		_cal_end_date date;
		_cal_start_date date;
	BEGIN
		-- RAISE DEBUG 'Calculate calendar %, _rank = %, recalculate = %', _calendar_id, _rank, _recalculate_included_calendar;
		_cal_elt_rank_found := FALSE;
		_cal_elt_number := 0;
		_rank_to_ignore := 0; -- There is never rank = 0 (start at 1)
		-- If we want delete this element : don't take it into account for calculation
		IF _currentElementDeletion and NOT _recalculate_included_calendar THEN
			_rank_to_ignore := _rank;
			-- RAISE DEBUG 'This is DELETION : rank to ignore = %', _rank;
		END IF;
		BEGIN
			-- If there is not any calendar element in this calendar then we don't go in the loop.
			FOR _cal IN
				SELECT id, operator, start_date, end_date, rank, interval, included_calendar_id FROM calendar_element WHERE calendar_id = _calendar_id AND rank != _rank_to_ignore ORDER BY rank
			LOOP
				-- RAISE DEBUG 'CalElt % : start = %, end = %, operator = %, rank = %, included_calendar_id = %', _cal.id, _cal_start_date, _cal.end_date, _cal.operator, _cal.rank, _cal.included_calendar_id;
				IF _recalculate_included_calendar AND (_cal.included_calendar_id IS NOT NULL) THEN
					SELECT * FROM computecalendarsstartend(_cal.included_calendar_id, NULL, NULL, NULL, NULL, TRUE, NULL, TRUE) INTO _recalculated_date_pair;
					-- RAISE DEBUG 'This is UPDATE : cal elt % which include calendar % : _recalculated_date_pair = (%,%)', _cal.id, _cal.included_calendar_id, _recalculated_date_pair.start_date,_recalculated_date_pair.end_date;
					-- Record new computed dates in calendar element
					UPDATE calendar_element SET start_date = _recalculated_date_pair.start_date, end_date = _recalculated_date_pair.end_date WHERE id = _cal.id;
					_cal_end_date := _recalculated_date_pair.end_date;
					_cal_start_date := _recalculated_date_pair.start_date;
				ELSE
					_cal_end_date := _cal.end_date;
					_cal_start_date := _cal.start_date;
				END IF;
				-- Note that we use start_date & end_date of a calendar element with an included calendar_id
				-- It is working only because we always duplicate computed_start_date/ computed_end_date of a calendar in all calendar element witch include it !
				-- First we need to remember the first date bounds
				IF _cal_elt_number = 0 THEN -- Must be true for _cal.rank = 1
					IF _cal_start_date IS NULL THEN
						_computed_date_pair.mask_length := 0;
						_computed_date_pair.start_date := NULL;
						_computed_date_pair.end_date := NULL;
						_computed_date_pair.bit_mask := NULL;
					ELSE
						_computed_date_pair.mask_length := (_cal_end_date - _cal_start_date )+ 1;
						_computed_date_pair.start_date := _cal_start_date;
						_computed_date_pair.end_date := _cal_end_date;
						_computed_date_pair.bit_mask := getcalendarelementbitmask(_cal_start_date, _cal_end_date, _computed_date_pair.mask_length, _cal.included_calendar_id, _cal_start_date, _cal_end_date, _cal.interval);
					END IF;
				ELSE
					-- Second (_rank>1) we need to calculate new bounds
					IF _cal.rank = _rank THEN
						-- RAISE DEBUG 'This is the element of rank %', _cal.rank;
						_cal_elt_rank_found := TRUE;
						-- In that case we MUST use the new start/end dates (because the current one could be false until COMMIT)
						SELECT * FROM atomicdatecomputation(_start_date, _end_date, _bit_mask, ((_end_date - _start_date )+ 1)::smallint, _operator,  _computed_date_pair) INTO _computed_date_pair;
					ELSE
						-- RAISE DEBUG 'Element of rank %', _cal.rank;
						-- TODO : delete this when cache mecanism ready
						IF _cal_start_date IS NULL THEN
							_cal_mask_lenght := 0;
							_cal_bit_mask := NULL;
						ELSE
							_cal_mask_lenght := (_cal_end_date - _cal_start_date )+ 1;
							_cal_bit_mask := getcalendarelementbitmask(_cal_start_date, _cal_end_date, _cal_mask_lenght, _cal.included_calendar_id, _cal_start_date, _cal_end_date, _cal.interval);
						END IF;
						SELECT * FROM atomicdatecomputation(_cal_start_date, _cal_end_date, _cal_bit_mask, _cal_mask_lenght, _cal.operator, _computed_date_pair) INTO _computed_date_pair;
					END IF;
				END IF;
				_cal_elt_number := _cal_elt_number + 1;
				-- RAISE DEBUG 'Computed = (%,%) : % (%)',_computed_date_pair.start_date,_computed_date_pair.end_date,_computed_date_pair.bit_mask,_computed_date_pair.mask_length;
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
						_computed_date_pair.bit_mask := _bit_mask;
						IF _end_date IS NULL THEN
							_computed_date_pair.mask_length := 0;
						ELSE
							_computed_date_pair.mask_length := (_end_date - _start_date) + 1;
						END IF;
					ELSE
						-- There is already calendar elements but the current one is new
						SELECT * FROM atomicdatecomputation(_start_date, _end_date, _bit_mask, ((_end_date - _start_date )+ 1)::smallint, _operator, _computed_date_pair) INTO _computed_date_pair;
					END IF;
				END IF;
			END IF;
			-- TODO : add cache information ?
			-- RAISE DEBUG 'Set calendar % computed date to (%,%)', _calendar_id,_computed_date_pair.start_date,_computed_date_pair.end_date;
			UPDATE calendar SET computed_start_date = _computed_date_pair.start_date, computed_end_date = _computed_date_pair.end_date WHERE id = _calendar_id;
		EXCEPTION WHEN raise_exception THEN
			RAISE EXCEPTION '% %An atomic calendar operation failed for calendar %',SQLERRM , chr(10), _calendar_id;
		END;
		RETURN _computed_date_pair;
	END;
    $$;
COMMENT ON FUNCTION computecalendarsstartend(integer, date, date, integer, calendar_operator, boolean, bit varying, boolean) IS 'Calculate start/end computed dates of a calendar. Result could be a pair of null if no date intersect or empty calendar';

-- If _bit_mask is given, ignore interval
CREATE OR REPLACE FUNCTION propagateparentcalendarsstartend (_calendar_id integer, _rank integer, _currentElementDeletion boolean, _start_date date default null, _end_date date default null, _operator calendar_operator default null, _bit_mask bit varying default null) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
		_cal record;
		_computed_date_pair date_pair;
    BEGIN
		BEGIN
			-- Calculate new start/end computed date for current calendar
			SELECT * FROM computecalendarsstartend(_calendar_id, _start_date, _end_date, _rank, _operator, _currentElementDeletion, _bit_mask) INTO _computed_date_pair;
			-- Launch same operation an all parent calendars (could have none)
			-- Infinite recursion must not happen because we previously check it with 'detectcalendarinclusionloop' function
			FOR _cal IN
				SELECT id, calendar_id, rank, operator FROM calendar_element WHERE _calendar_id = included_calendar_id
			LOOP
				-- Need to update current calendar element with new calculated values
				UPDATE calendar_element SET start_date = _computed_date_pair.start_date, end_date = _computed_date_pair.end_date WHERE id = _cal.id;
				-- To calculate the parent calendar, we need to pass (not commited yet) new start/end date of updated calendar_element (and rand to found it)
				-- operator is passed because of the not already added calendar element (first call of this recursive function)
				-- We set currentElementDeletion, because just want to update fields, ignoring no calendar
				PERFORM propagateparentcalendarsstartend(_cal.calendar_id, _cal.rank, FALSE, _computed_date_pair.start_date, _computed_date_pair.end_date, _cal.operator, _computed_date_pair.bit_mask);
			END LOOP;
		EXCEPTION WHEN raise_exception THEN
			RAISE EXCEPTION '% %Parent calendar element = %',SQLERRM , chr(10), _calendar_id;
		END;
    END;
    $$;
COMMENT ON FUNCTION propagateparentcalendarsstartend(integer, integer, boolean, date, date, calendar_operator, bit varying) IS 'This recursive function launch computecalendarsstartend and call himself on an all parents calendar';



CREATE OR REPLACE FUNCTION insertcalendarelement(_calendar_id integer, _start_date date default NULL, _end_date date default NULL, _interval integer default 1, _operator calendar_operator default '+', _included_calendar_id integer default NULL) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _id integer;
		_rank integer;
		_real_start_date date;
		_real_end_date date;
		_included_cal record;
        _parent_cal record;
		_bitmask bit varying;
    BEGIN
		IF _included_calendar_id IS NOT NULL THEN
			-- Integrity control : a calendar element with an included_calendar_id could not have start_date & end_date provided
			IF _start_date IS NOT NULL OR _end_date IS NOT NULL THEN
				RAISE EXCEPTION 'A calendar element with an included_calendar_id could not have start_date & end_date provided !';
			END IF;
			IF _interval != 1 THEN
				RAISE EXCEPTION 'A calendar element with an included_calendar_id could not have an interval not equal to 1 !';
			END IF;
			-- Abort creation if calendar creation will create an inclusion loop
			BEGIN
				PERFORM detectcalendarinclusionloop(_included_calendar_id, _calendar_id);
			EXCEPTION WHEN raise_exception THEN
				RAISE EXCEPTION '% %Cannot insert calendar. It will create an inclusion loop !',SQLERRM , chr(10);
			END;
			-- We need to extract start/end date from included calendar
			SELECT computed_start_date, computed_end_date, calendar_type FROM calendar WHERE id = _included_calendar_id INTO _included_cal;
            SELECT calendar_type FROM calendar WHERE id = _calendar_id INTO _parent_cal;
			IF _included_cal.calendar_type = 'accessibilite'::calendar_type AND _parent_cal.calendar_type != 'accessibilite'::calendar_type THEN
				RAISE EXCEPTION '"accessibilite" calendars can only be included into a calendar of type "accessibilite"!';
			END IF;
			-- Note that dates could be NULL
			_real_start_date := _included_cal.computed_start_date;
			_real_end_date := _included_cal.computed_end_date;
			_bitmask := getcalendarelementbitmask(_real_start_date, _real_end_date, (_real_end_date - _real_start_date) + 1, _included_calendar_id, _real_start_date, _real_end_date, _interval);
		ELSE
			IF _start_date IS NULL OR _end_date IS NULL THEN
				RAISE EXCEPTION 'You must provide start_date+end_date or included calendar !';
			END IF;
			_real_start_date := _start_date;
			IF _interval != 1 THEN -- In that case we need to recalculate end_date
				-- Substract modulo to end_date (could be 0)
				_real_end_date := _end_date + cast ((_start_date - _end_date)%_interval || 'day' as interval);
			ELSE
				_real_end_date := _end_date;
			END IF;
			_bitmask := getcalendarelementbitmask(_real_start_date, _real_end_date, (_real_end_date - _real_start_date) + 1, NULL, _real_start_date, _real_end_date, _interval);
		END IF;
		-- At this point if _real_start_date or _real_end_date are null we know that there is an empty calendar underneath

		-- Second, calculate the rank of element
		SELECT count(*) FROM calendar_element WHERE calendar_id = _calendar_id INTO _rank;
		_rank := _rank + 1;

		-- RAISE DEBUG 'We insert a new element of rank %, date are (%, %)', _rank, _real_start_date, _real_end_date;
		-- Third, recalculate calendar start/end computed dates and recursively for all calendars that include this one
		BEGIN
			-- The new calendar_element is not already inserted so we need to pass information about it on sub routines
			PERFORM propagateparentcalendarsstartend(_calendar_id, _rank, FALSE, _real_start_date, _real_end_date, _operator, _bitmask);
		EXCEPTION WHEN raise_exception THEN
				RAISE EXCEPTION '% %Cannot insert calendar. It broke start stop rule somewhere !',SQLERRM , chr(10);
		END;
		-- Finally, we can commit transaction and insert calendar
        INSERT INTO calendar_element(calendar_id, rank, start_date, end_date, operator, interval, included_calendar_id) VALUES(_calendar_id, _rank, _real_start_date, _real_end_date, _operator, _interval, _included_calendar_id) RETURNING id INTO _id;
        RETURN _id;
    END;
    $$;
COMMENT ON FUNCTION insertcalendarelement (integer, date, date, integer, calendar_operator, integer) IS 'Insert record in table calendar_element and return new id. Will RAISE if insertion cause start > end of a linked calendar. Trig a recalculation of parent calendars computed start stop date';



CREATE OR REPLACE FUNCTION deletecalendarelement(_calendar_element_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_new_rank integer;
		_other_cal_elt record;
		_cal_elt record;
		_operator calendar_operator;
    BEGIN
		-- Get rank of deleted element
		SELECT rank, calendar_id FROM calendar_element WHERE id = _calendar_element_id INTO _cal_elt;
		IF _cal_elt.rank = 1 THEN
			SELECT operator FROM calendar_element WHERE calendar_id = _cal_elt.calendar_id AND rank = 2 INTO _operator;
			IF FOUND THEN
				IF _operator != '+'::calendar_operator THEN
					RAISE EXCEPTION 'You cannot delete this rank 1 calendar because rank 2 calendar is not of "+" operator';
				END IF;
			END IF;
		END IF;
		-- Update calendars depending of the current one
        PERFORM propagateparentcalendarsstartend(_cal_elt.calendar_id, _cal_elt.rank, TRUE);
		-- Decrease rank of all element up to the current one
		FOR _other_cal_elt IN
			SELECT id, rank FROM calendar_element WHERE calendar_id = _cal_elt.calendar_id AND rank > _cal_elt.rank
		LOOP
			_new_rank := _other_cal_elt.rank - 1;
			UPDATE calendar_element SET rank = _new_rank WHERE id = _other_cal_elt.id;
		END LOOP;
		-- Finally we delete the element
		DELETE FROM calendar_element WHERE id = _calendar_element_id;
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



CREATE OR REPLACE FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer, _calendar_type calendar_type default 'mixte',  _operator calendar_operator default '+') RETURNS void
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
            INSERT INTO calendar(name, calendar_type, line_version_id) VALUES (_name, _calendar_type, _lvid);
            INSERT INTO calendar_datasource(calendar_id, code, datasource_id) VALUES (currval('calendar_id_seq'), _tcode, _datasource);
            UPDATE trip SET period_calendar_id =  currval('calendar_id_seq') WHERE id = _trip_id;
			PERFORM insertcalendarelement(currval('calendar_id_seq')::integer, _date, _date, 1, _operator);
        ELSE
			PERFORM insertcalendarelement(_calendar_id, _date, _date, 1, _operator);
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer, _calendar_type calendar_type, _operator calendar_operator) IS 'Insertion selon condition de nouvelles entrées calendar, calendar_datasource et calendar_element plus mise à jour dune entrée trip associée à ces nouveaux calendriers. Si le calendrier rattaché au trip existe déjà lors de lappel de cette fonction, elle effectuera une simple insertion dune entrée calendar_element.';

CREATE TYPE address AS (address character varying, the_geom character varying, is_entrance boolean);

CREATE OR REPLACE FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _on_schema boolean, _datasource integer, _is_velo boolean, _addresses address[], _stop_codes varchar[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _type_id integer;
        _poi_id integer;
        _real_geom pgis.geometry(Point, 3943);
        _address address;
        _stop_id integer;
        _stop_code character varying;
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
        INSERT INTO poi(name, city_id, poi_type_id, priority, on_schema) VALUES (_name, _city_id, _type_id, _priority, _on_schema) RETURNING id INTO _poi_id;
        INSERT INTO poi_datasource(poi_id, code, datasource_id) VALUES (_poi_id, '', _datasource);
        FOREACH _address IN ARRAY _addresses
        LOOP
            _real_geom := pgis.ST_GeomFromText(_address.the_geom, 3943);
            INSERT INTO poi_address(poi_id, address, is_entrance, the_geom) VALUES (_poi_id, _address.address, _address.is_entrance, _real_geom);
        END LOOP;
        IF _stop_codes IS NOT NULL THEN
            FOREACH _stop_code IN ARRAY _stop_codes
            LOOP
                SELECT stop_id FROM stop_datasource WHERE code = _stop_code INTO _stop_id;
                IF _stop_id IS NOT NULL THEN
                    INSERT INTO poi_stop(poi_id, stop_id) VALUES(_poi_id, _stop_id);
                END IF;
            END LOOP;
        END IF;
    END;
    $$;
COMMENT ON FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _on_schema boolean, _datasource integer, _is_velo boolean, addresses address[], _stop_codes varchar[]) IS 'Insertion de nouvelles entrées poi, poi_datasource et si passées en paramètre, poi_adress. Les poi_adress sont passées dans le tableau addresses qui contient des types address (le type address est un type technique contenant les champs nécessaires à linsertion dune entrée poi_address). Ainsi toutes les entrées poi_address seront associées à la donnée poi nouvellement créée.';


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


CREATE OR REPLACE FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _route_section_id integer, _start_date date, _end_date date) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _real_geom pgis.geometry(Linestring, 3943);
        _new_route_section_id integer;
    BEGIN
        _real_geom := pgis.ST_GeomFromText(_the_geom, 3943);
        UPDATE route_section SET end_date = _end_date WHERE id = _route_section_id;
        INSERT INTO route_section(start_stop_id, end_stop_id, start_date, the_geom) VALUES (_start_stop_id, _end_stop_id, _start_date, _real_geom) RETURNING id INTO _new_route_section_id;
        UPDATE route_stop SET route_section_id = _new_route_section_id WHERE route_section_id = _route_section_id AND route_id IN (SELECT R.id FROM route R JOIN line_version LV ON LV.id = R.line_version_id WHERE ((LV.end_date IS NULL AND LV.planned_end_date >= _start_date) OR LV.end_date >= _start_date));
    END;
    $$;
COMMENT ON FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _route_section_id integer, _start_date date, _end_date date) IS 'La mise à jour dune route_section est historisée. Cela implique la fermeture dune route_section (champ end_date prend une valeur) et la création de sa successeur avec un champ end_date vide.';


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


CREATE OR REPLACE FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _code character varying, _insee character varying, _master_stop_id integer, _datasource integer, _srid integer default 27572)
    RETURNS integer AS $$
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
        ELSIF _master_stop_id IS NOT NULL THEN
            SELECT insertortransformtophantom(NULL, _master_stop_id, _datasource, _code) INTO _stop_id;
        ELSE
            INSERT INTO waypoint(id) VALUES (nextval('waypoint_id_seq')) RETURNING waypoint.id INTO _stop_id;
            INSERT INTO stop(id, stop_area_id, master_stop_id) VALUES (_stop_id, _stop_area_id, _master_stop_id);
            INSERT INTO stop_datasource(stop_id, datasource_id, code) VALUES (_stop_id, _datasource, _code);
            INSERT INTO stop_history(stop_id, start_date, short_name, the_geom) VALUES (_stop_id, _date, _name, _the_geom);

            PERFORM setstopaccessibility(_stop_id, _access, _accessibility_mode_id, _code, _datasource);
        END IF;

        RETURN _stop_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _code character varying, _insee character varying, _master_stop_id integer, _datasource integer, _srid integer) IS 'Insertion de 4 nouvelles entrées : un waypoint et un stop qui possèderont le même ID, puis les stop_datasource et stop_history associés au nouveau stop. La géométrie du stop_history est construite depuis des valeurs x/y passées en paramètre. Ces valeurs sont issues dun SRID 27572 (sortie HASTUS) et la géométrie finale est passée en SRID 3943.';


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


CREATE OR REPLACE FUNCTION inserttrip(_name character varying, _tcode character varying, _rcode character varying, _lvid integer, _datasource integer, _day_calendar_id integer default NULL, _period_calendar_id integer default NULL) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _route_id integer;
    BEGIN
        SELECT R.id INTO _route_id FROM route R JOIN route_datasource RD ON R.id = RD.route_id WHERE RD.code = _rcode AND R.line_version_id = _lvid;
        INSERT INTO trip(name, route_id, day_calendar_id, period_calendar_id) VALUES (_name, _route_id, _day_calendar_id, _period_calendar_id);
        INSERT INTO trip_datasource(trip_id, datasource_id, code) VALUES (currval('trip_id_seq'), _datasource, _tcode);
    END;
    $$;
COMMENT ON FUNCTION inserttrip (character varying, character varying, character varying, integer, integer, integer, integer) IS 'Insertion dun nouveau trip et de sa datasource associée. Le trip est directement rattaché à une route dont lid est récupéré grâce aux paramètres _rcode et _lvid.';


CREATE OR REPLACE FUNCTION mergetrips(_trips integer[], _trip_calendar_id integer, _datasource_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _trip_parent_id integer;
    BEGIN
        -- creating a new trip_parent using first trip in array
        INSERT INTO trip(name, route_id, trip_calendar_id) SELECT name || '_FH', route_id, _trip_calendar_id FROM trip WHERE id = _trips[1] RETURNING id INTO _trip_parent_id;
        INSERT INTO trip_datasource(trip_id, datasource_id, code) VALUES(_trip_parent_id, _datasource_id, _trip_parent_id || '_FH');
        -- duplicating all stop_time linked to the first trip and link them to the new _trip_parent_id
        INSERT INTO stop_time(route_stop_id, trip_id, departure_time, arrival_time) SELECT route_stop_id, _trip_parent_id, departure_time, arrival_time FROM stop_time WHERE trip_id = _trips[1];
        -- updating all _trips by linking them to the new _trip_parent_id and deleting their trip_calendar_id and comment_id
        UPDATE trip SET(trip_calendar_id, trip_parent_id) = (NULL, _trip_parent_id) WHERE id = ANY(_trips);
    END;
    $$;
COMMENT ON FUNCTION mergetrips (_trips integer[], _trip_calendar_id integer, _datasource_id integer) IS 'Merging duplicated trips by creating a new one attached to a specific _trip_calendar_id. The trip_calendar days pattern is the sum of all patterns of each trip which will be merged.';


CREATE OR REPLACE FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _master_stop_id integer,  _datasource integer) RETURNS void
    AS $$
    DECLARE
        _stop_id integer;
        _temp_geom character varying;
        _the_geom pgis.geometry(Point, 3943);
        _next_start_date date;
    BEGIN
        _temp_geom := 'POINT(' || _x || ' ' || _y || ')';
        _the_geom := pgis.ST_Transform(pgis.ST_GeomFromText(_temp_geom, 27572), 3943);

        IF _master_stop_id IS NULL THEN
            UPDATE stop_history SET end_date = _date - interval '1 day' WHERE id = _stop_history_id RETURNING stop_id INTO _stop_id;
            SELECT MIN(start_date) INTO _next_start_date FROM stop_history WHERE stop_id = _stop_id AND start_date > _date;
            INSERT INTO stop_history(stop_id, start_date, end_date, short_name, the_geom) VALUES (_stop_id, _date, _next_start_date - interval '1 day',_name, _the_geom);
        END IF;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean, _accessibility_mode_id integer, _master_stop_id integer,  _datasource integer) IS 'La mise à jour dun stop est historisée. Cela implique la fermeture de la version courante dun stop_history en appliquant une date au champ end_date puis en la création de son successeur avec un champ end_date vide.';


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


CREATE OR REPLACE FUNCTION insertlineversion(_line_id integer, _version integer, _start_date date, _end_date date, _planned_end_date date, _name character varying, _forward_direction character varying, _backward_direction character varying, _bg_color character varying, _bg_hexa_color character varying, _fg_color character varying, _fg_hexa_color character varying, _accessibility boolean, _air_conditioned boolean, _certified boolean, _comment text, _depot character varying, _datasource integer, _code character varying)
    RETURNS integer AS $$
    DECLARE
        _line_version_id integer;
    BEGIN
		UPDATE line_version SET end_date = current_date WHERE end_date IS NULL AND line_id = _line_id;
        INSERT INTO line_version (line_id, version, start_date, end_date, planned_end_date, name, forward_direction, backward_direction, bg_color, bg_hexa_color, fg_color, fg_hexa_color, accessibility, air_conditioned, certified, comment, depot) VALUES (_line_id, _version, _start_date, _end_date, _planned_end_date, _name, _forward_direction, _backward_direction, _bg_color, _bg_hexa_color, _fg_color, _fg_hexa_color, _accessibility, _air_conditioned, _certified, _comment, _depot) RETURNING line_version.id INTO _line_version_id;
        INSERT INTO line_version_datasource (line_version_id, datasource_id, code) VALUES (_line_version_id, _datasource, _code);
        RETURN _line_version_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertlineversion (integer, integer, date, date, date, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean, text, character varying, integer, character varying) IS 'Insert record in tables line_version and line_version_datasource and return the new line_version.id';


CREATE OR REPLACE FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer, _date date default CURRENT_DATE) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _accessibility_date date;
        _calendar_id integer;
        _hastus_calendar_id integer;
        _calendar_element_id integer;
        _max_date date;
        _is_currently_accessible boolean;
    BEGIN
        SELECT value FROM global_vars WHERE name = 'maximum_calendar_date' INTO _max_date;

        -- Check if there is already a calendar
        SELECT
            calendar_id INTO _calendar_id
        FROM accessibility_type a
        JOIN stop_accessibility s ON s.accessibility_type_id = a.id
        WHERE
            a.accessibility_mode_id = _accessibility_mode_id AND
            s.stop_id = _stop_id;

        -- If there is not create all the objects
        IF _calendar_id IS NULL THEN
            SELECT insertcalendar(CONCAT('SP_', _datasource, ':', _code, '_', _accessibility_mode_id), _code, _datasource, 'accessibilite') INTO _calendar_id;
            SELECT insertcalendar(CONCAT('SP_', _datasource, ':', _code, '_', _accessibility_mode_id, '_HASTUS'), _code, _datasource, 'accessibilite') INTO _hastus_calendar_id;
            PERFORM insertcalendarelement(_calendar_id, NULL, NULL, 1, '+', _hastus_calendar_id);
            INSERT INTO accessibility_type(accessibility_mode_id, calendar_id) VALUES (_accessibility_mode_id, _calendar_id);
            INSERT INTO stop_accessibility(accessibility_type_id, stop_id) VALUES (currval('accessibility_type_id_seq'), _stop_id);
        -- Otherwise get the hastus inaccessibility calendar
        ELSE
            SELECT id INTO _hastus_calendar_id FROM calendar WHERE name = CONCAT('SP_', _datasource, ':', _code, '_', _accessibility_mode_id, '_HASTUS');
        END IF;

        -- Select current accessibility state for Hastus
        SELECT id INTO _calendar_element_id
        FROM calendar_element
        WHERE
            calendar_id = _hastus_calendar_id AND
            start_date <= _date AND
            end_date >= _date
        LIMIT 1;
        _is_currently_accessible := _calendar_element_id IS NULL;

        -- Update if necessary, add an element if the stop is now inaccessible or just set end date to yesterday if it became accessible
        IF _is_currently_accessible != _access THEN
            IF _access THEN
                DELETE FROM calendar_element
                WHERE
                    calendar_id = _hastus_calendar_id AND
                    start_date >= _date;

                UPDATE calendar_element
                SET
                    end_date = _date - 1
                WHERE
                    calendar_id = _hastus_calendar_id AND
                    end_date >= _date;
            ELSE
                PERFORM insertcalendarelement(_hastus_calendar_id, _date, _max_date);
            END IF;
        END IF;
    END;
    $$;
COMMENT ON FUNCTION setstopaccessibility(_stop_id integer, _access boolean, _accessibility_mode_id integer, _code character varying, _datasource integer, _date date) IS 'Insert or update access(_access)  for an accessibility mode(_accessibility_mode_id) for the selected stop(_stop_id) and return the new stop_accessibility.id. _code is used,  if necessary, for the associated calendar.name ';


CREATE OR REPLACE FUNCTION stopisaccessible(_stop_id integer, _accessibility_mode_id integer, _date date default CURRENT_DATE)
    RETURNS boolean AS $$
    DECLARE
        _master_stop_id integer;
        _calendar_id integer;
        _bit_mask bit varying;
        _result boolean;
    BEGIN
        SELECT master_stop_id INTO _master_stop_id FROM stop WHERE id = _stop_id;

        -- phantom stop case => master_stop holds the accessibility
        IF _master_stop_id IS NOT NULL THEN
            SELECT stopisaccessible(_master_stop_id, _accessibility_mode_id, _date) INTO _result;
        ELSE
            SELECT
                calendar_id INTO _calendar_id
            FROM accessibility_type a
            JOIN stop_accessibility s ON s.accessibility_type_id = a.id
            WHERE
                a.accessibility_mode_id = _accessibility_mode_id AND
                s.stop_id = _stop_id;

            _bit_mask := getcalendarbitmask(_calendar_id, _date, _date + 1);
            _result := _bit_mask::text LIKE '0%';
        END IF;

        RETURN _result;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION stopisaccessible(_stop_id integer, _accessibility_mode_id integer, _date date) IS 'Return true if _stop_id is accessible at the date';

CREATE OR REPLACE FUNCTION purge_fh_data(_line_version_id integer) RETURNS VOID
    AS $$
    DECLARE
        _route_stop_id integer;
        _trip_id integer;
    BEGIN
        FOR _trip_id IN SELECT t.id FROM trip t JOIN route r ON r.id = t.route_id JOIN line_version lv ON lv.id = r.line_version_id WHERE lv.id = _line_version_id AND t.period_calendar_id IS NULL AND t.day_calendar_id IS NULL AND t.id NOT IN (SELECT DISTINCT(trip_parent_id) FROM trip WHERE trip_parent_id IS NOT NULL AND (period_calendar_id IS NOT NULL OR day_calendar_id IS NOT NULL))
        LOOP
            DELETE FROM stop_time WHERE trip_id = _trip_id;
            DELETE FROM route_stop WHERE id NOT IN (SELECT DISTINCT(route_stop_id) FROM stop_time);
            DELETE FROM trip_datasource WHERE trip_id = _trip_id;
            DELETE FROM trip WHERE id = _trip_id;
        END LOOP;
        DELETE FROM comment WHERE id NOT IN (SELECT distinct(comment_id) FROM trip) AND id NOT IN (SELECT DISTINCT(comment_id) FROM route);
        DELETE FROM grid_link_calendar_mask_type WHERE grid_calendar_id IN (SELECT id FROM grid_calendar WHERE line_version_id = _line_version_id);
        DELETE FROM trip_calendar WHERE id NOT IN (SELECT DISTINCT(trip_calendar_id) FROM trip);
        DELETE FROM grid_link_calendar_mask_type WHERE grid_mask_type_id NOT IN (SELECT DISTINCT(grid_mask_type_id) FROM trip_calendar);
        DELETE FROM grid_mask_type WHERE id NOT IN (SELECT DISTINCT(grid_mask_type_id) FROM trip_calendar);
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION purge_fh_data(integer) IS 'Efface toutes les données de type fiche horaire relatives à une line_version.';

CREATE OR REPLACE FUNCTION insertortransformtophantom(_stop_id integer, _master_stop_id integer, datasource_id integer, code varchar) RETURNS integer
    AS $$
    DECLARE
        _calendar_id integer;
        _hastus_calendar_id integer;
        _stop_accessibility record;
        _odt_stop record;
        _accessibility_mode varchar;
        _type_references integer;
    BEGIN
         IF _master_stop_id IS NOT NULL THEN
            -- Insert stop if it doesn't exists
            IF _stop_id IS NULL THEN
                INSERT INTO waypoint(id) VALUES (nextval('waypoint_id_seq')) RETURNING waypoint.id INTO _stop_id;
                INSERT INTO stop(id, master_stop_id) VALUES (_stop_id, _master_stop_id);
                INSERT INTO stop_datasource(stop_id, datasource_id, code) VALUES (_stop_id, _datasource, _code);
            -- Update it otherwise and clean accessibility and history
            ELSE
                UPDATE stop set master_stop_id = _master_stop_id, stop_area_id = NULL WHERE id = _stop_id;

                -- remove transfers
                DELETE FROM transfer_accessibility WHERE id IN (SELECT id FROM transfer WHERE start_stop_id = _stop_id OR end_stop_id = _stop_id);
                DELETE FROM transfer WHERE start_stop_id = _stop_id OR end_stop_id = _stop_id;

                -- remove stop accessibility
                FOR _stop_accessibility IN
                    SELECT id, accessibility_type_id FROM stop_accessibility WHERE stop_id = _stop_id
                LOOP
                    SELECT name INTO _accessibility_mode FROM accessibility_type at JOIN accessibility_mode am ON at.accessibility_mode_id = am.id WHERE at.id = _stop_accessibility.accessibility_type_id;
                    IF name LIKE 'UFR' THEN
                        SELECT calendar_id INTO _calendar_id FROM accessibility_type WHERE id = _stop_accessibility.accessibility_type_id;
                        SELECT calendar_id INTO _hastus_calendar_id FROM calendar WHERE name = CONCAT('SP_', _datasource, ':', _code, '_1_HASTUS');
                        DELETE FROM calendar_element WHERE calendar_id IN (_calendar_id, _hastus_calendar_id);
                        DELETE FROM calendar_datasource WHERE calendar_id IN (_calendar_id, _hastus_calendar_id);
                        DELETE FROM calendar WHERE id IN (_hastus_calendar_id, _calendar_id);
                        DELETE FROM stop_accessibility WHERE id = _stop_accessibility.id;
                        DELETE FROM accessibility_type WHERE id = _stop_accessibility.accessibility_type_id;
                    ELSE
                        DELETE FROM stop_accessibility WHERE id = _stop_accessibility.id;
                SELECT
                            COUNT(*) INTO _type_references
                        FROM (
                            SELECT id FROM poi_address_accessibility WHERE accessibility_type_id = _stop_accessibility.accessibility_type_id
                                UNION
                            SELECT id FROM transfer_accessibility WHERE accessibility_type_id = _stop_accessibility.accessibility_type_id
                                UNION
                            SELECT id FROM trip_accessibility WHERE accessibility_type_id = _stop_accessibility.accessibility_type_id
                        ) AS accessibility_union;
                        IF _type_references = 0 THEN
                            DELETE FROM accessibility_type WHERE id = _stop_accessibility.accessibility_type_id;
                        END IF;
                    END IF;
                END LOOP;

                -- remove stop histories but log them before
                INSERT INTO log
                    (datetime, table_name, action, user_login, previous_data)
                    SELECT
                        NOW(), 'stop_history', 'DELETE', 'hastus', formatrowtolog('stop_history', id)
                    FROM stop_history
                    WHERE stop_id = _stop_id
                ;
                DELETE FROM stop_history WHERE stop_id = _stop_id;

                -- remove odt stops but log them before, play with the offset since the primary key is made of multiple values
                FOR _odt_stop IN
                    SELECT ROW_NUMBER() OVER () - 1 AS position FROM odt_stop WHERE stop_id = _stop_id
                LOOP
                    INSERT INTO log
                        (datetime, table_name, action, user_login, previous_data)
                        SELECT
                            NOW(), 'odt_stop', 'DELETE', 'hastus', formatrowtolog('odt_stop', _stop_id, 'stop_id', _odt_stop.position::integer)
                        FROM odt_stop LIMIT 1 OFFSET _odt_stop.position;
                END LOOP;
                DELETE FROM odt_stop WHERE stop_id = _stop_id;
            END IF;
        ELSE
            RAISE EXCEPTION 'This procedure should only be used to insert phantom stops';
        END IF;

        RETURN _stop_id;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION insertortransformtophantom(integer, integer, integer, varchar) IS 'Insert a phantom or transform a normal stop into one by setting its master and cleaning history and accessibility for the stop.';

CREATE OR REPLACE FUNCTION formatrowtolog(_table_name varchar, _id integer, _pk_column varchar default 'id', _offset integer default 0) RETURNS varchar
    AS $$
    DECLARE
        _column record;
        _record record;
        _result varchar;
        _tmp_vc varchar;
        _variable_cast varchar;
    BEGIN
        FOR
            _column IN
            SELECT column_name::varchar AS name, udt_name AS usertype
            FROM information_schema.columns
            WHERE
                table_schema = 'public' AND
                table_name = _table_name
            ORDER BY ordinal_position
        LOOP
            IF _column.usertype = 'geometry' THEN
                _variable_cast = format('COALESCE(ST_AsText(%s)::varchar, ''null'')', _column.name);
            ELSE
                _variable_cast = format('COALESCE(%s::varchar, ''null'')', _column.name);
            END IF;
            EXECUTE format('SELECT %s FROM %I WHERE %I = %L LIMIT 1 OFFSET %s', _variable_cast, _table_name, _pk_column, _id, _offset) INTO _tmp_vc;
            _result = CONCAT(
                _result,
                CASE WHEN _result IS NULL THEN '' ELSE ' ' END,
                CONCAT(
                    LOWER(LEFT(_column.name, 1)),
                    SUBSTR(REPLACE(INITCAP(_column.name), '_', ''), 2)
                ),
                ':{', _tmp_vc, '}'
            );
        END LOOP;

        RETURN _result;
    END;
    $$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION formatrowtolog(varchar, integer, varchar, integer) IS 'Format a row define by its id in a table defined by its name for logging purpose. Result string is columnName:{value} columnOtherName:{null}... Return the first result only, take that into account if the id you provide isn''t unique, you can provide an offset for the default ordering.';
