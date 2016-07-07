DROP FUNCTION IF EXISTS check_exception_on_trip_trip_calendar_update() CASCADE;
DROP FUNCTION IF EXISTS add_exceptions() CASCADE;
DROP FUNCTION IF EXISTS delete_exceptions() CASCADE;
DROP FUNCTION IF EXISTS delete_overlaps_calendar() CASCADE;

CREATE OR REPLACE FUNCTION check_exception_on_trip_trip_calendar_update() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _gc_pattern varchar(7);
        _tc_pattern varchar(7);
        _exception_type record;
        _comment_id integer;
    BEGIN
        IF NEW.trip_calendar_id IS NULL THEN
            IF OLD.comment_id IS NOT NULL THEN
                NEW.comment_id := NULL;
            END IF;
        ELSE
            SELECT
                concat(gc.monday::int, gc.tuesday::int, gc.wednesday::int, gc.thursday::int, gc.friday::int, gc.saturday::int, gc.sunday::int),
                concat(tc.monday::int, tc.tuesday::int, tc.wednesday::int, tc.thursday::int, tc.friday::int, tc.saturday::int, tc.sunday::int)
            FROM trip t
            JOIN route r ON r.id = t.route_id
            JOIN grid_calendar gc ON gc.line_version_id = r.line_version_id
            JOIN trip_calendar tc ON tc.id = NEW.trip_calendar_id
            JOIN grid_link_calendar_mask_type glcmt ON glcmt.grid_mask_type_id = tc.grid_mask_type_id AND glcmt.grid_calendar_id = gc.id
            WHERE t.id = NEW.id
            INTO _gc_pattern, _tc_pattern;
            IF _gc_pattern IS NOT NULL AND _tc_pattern IS NOT NULL AND _gc_pattern != _tc_pattern THEN

                SELECT * FROM exception_type WHERE grid_calendar_pattern = _gc_pattern AND trip_calendar_pattern = _tc_pattern INTO _exception_type;

                IF _exception_type IS NULL THEN
                    -- selecting default comment
                    SELECT id FROM comment WHERE label = 'zz' AND comment_text = 'Une exception a été détectée mais aucune action automatique na pu être effectuée.' INTO _comment_id;
                ELSE
                    -- checking that the comment associated to the exception_type already exists, if not creating it
                    SELECT id FROM comment WHERE comment_text = _exception_type.exception_text AND label = _exception_type.label INTO _comment_id;
                    IF _comment_id IS NULL THEN
                        INSERT INTO comment(label, comment_text) VALUES(_exception_type.label, _exception_type.exception_text) RETURNING id INTO _comment_id;
                    END IF;
                END IF;

                NEW.comment_id := _comment_id;
            END IF;
        END IF;
        RETURN NEW;
    END;
    $$;

CREATE TRIGGER check_exception_on_trip_trip_calendar_update
    BEFORE UPDATE ON trip
    FOR EACH ROW
    WHEN (OLD.trip_calendar_id IS DISTINCT FROM NEW.trip_calendar_id)
    EXECUTE PROCEDURE check_exception_on_trip_trip_calendar_update();

CREATE OR REPLACE FUNCTION add_exceptions() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _trip_calendar_id integer;
        _line_version_id integer;
        _gc_pattern varchar(7);
        _tc_pattern varchar(7);
        _exception_type record;
        _default_comment_id integer;
        _comment_id integer;
    BEGIN
        -- building the grid_calendar pattern corresponding to the new glcmt
        SELECT
            line_version_id,
            concat(monday::int, tuesday::int, wednesday::int, thursday::int, friday::int, saturday::int, sunday::int)
        FROM grid_calendar
        WHERE id = NEW.grid_calendar_id
        INTO _line_version_id, _gc_pattern;

        -- selecting default comment
        SELECT id FROM comment WHERE label = 'zz' AND comment_text = 'Une exception a été détectée mais aucune action automatique na pu être effectuée.' INTO _default_comment_id;

        -- for each trip_calendar linked to the grid_mask_type from new inserted glcmt: build pattern and compare it to grid_calendar pattern
        FOR _trip_calendar_id, _tc_pattern IN
            SELECT
                id,
                concat(monday::int, tuesday::int, wednesday::int, thursday::int, friday::int, saturday::int, sunday::int)
            FROM trip_calendar
            WHERE grid_mask_type_id = NEW.grid_mask_type_id
        LOOP
            -- if the two patterns are different an exception is needed on the related trips
            IF _gc_pattern != _tc_pattern THEN
                -- checking the exception_type exists, if not creating default comment otherwise creating a comment with the exception_type attributes
                SELECT * FROM exception_type WHERE grid_calendar_pattern = _gc_pattern AND trip_calendar_pattern = _tc_pattern INTO _exception_type;

                IF _exception_type IS NULL THEN
                    _comment_id := _default_comment_id;
                ELSE
                    -- checking that the comment associated to the exception_type already exists, if not creating it
                    SELECT id FROM comment WHERE comment_text = _exception_type.exception_text AND label = _exception_type.label INTO _comment_id;
                    IF _comment_id IS NULL THEN
                        INSERT INTO comment(label, comment_text) VALUES(_exception_type.label, _exception_type.exception_text) RETURNING id INTO _comment_id;
                    END IF;
                END IF;

                UPDATE trip SET comment_id = _comment_id
                WHERE id IN (
                    SELECT t.id
                    FROM trip t
                    JOIN route AS r ON r.id = t.route_id
                    WHERE r.line_version_id = _line_version_id AND t.trip_calendar_id = _trip_calendar_id
                );
            END IF;
       END LOOP;
       RETURN NEW;
    END;
    $$;
COMMENT ON FUNCTION add_exceptions() IS 'Detect exceptions and insert comments in trips according to multiple conditions. This function is triggered after insert/delete on table grid_link_calendar_mask_type.';

CREATE TRIGGER add_exceptions AFTER INSERT ON grid_link_calendar_mask_type
FOR EACH ROW EXECUTE PROCEDURE add_exceptions();

CREATE OR REPLACE FUNCTION delete_exceptions() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Detaching related trips from their comment (using grid_calendar_id and grid_mask_type_id)
        UPDATE trip SET comment_id = NULL
        WHERE id IN (
            SELECT t.id FROM trip t
            JOIN trip_calendar tc ON tc.id = t.trip_calendar_id
            JOIN route r ON r.id = t.route_id
            JOIN line_version lv ON lv.id = r.line_version_id
            JOIN grid_calendar gc ON gc.line_version_id = lv.id
            WHERE tc.grid_mask_type_id = OLD.grid_mask_type_id
            AND gc.id = OLD.grid_calendar_id
        );
        -- Deleting unused comments
        DELETE FROM comment WHERE id NOT IN (SELECT distinct(comment_id) FROM route WHERE comment_id IS NOT NULL) AND id NOT IN (SELECT distinct(comment_id) FROM trip WHERE comment_id IS NOT NULL) AND (label != 'zz' AND comment_text != 'Une exception a été détectée mais aucune action automatique na pu être effectuée.');
        RETURN OLD;
    END;
    $$;
COMMENT ON FUNCTION delete_exceptions() IS 'Deleting comment_id on trips related to the deleted grid_link_calendar_mask_type. Also cleaning unused comments except the default one.';

CREATE TRIGGER delete_exceptions BEFORE DELETE ON grid_link_calendar_mask_type
FOR EACH ROW EXECUTE PROCEDURE delete_exceptions();

CREATE TRIGGER before_update_exceptions BEFORE UPDATE ON grid_link_calendar_mask_type
FOR EACH ROW EXECUTE PROCEDURE delete_exceptions();

CREATE TRIGGER after_update_exceptions AFTER UPDATE ON grid_link_calendar_mask_type
FOR EACH ROW EXECUTE PROCEDURE add_exceptions();

CREATE OR REPLACE FUNCTION delete_overlaps_calendar() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _calendar_id integer;
    BEGIN
        IF NEW.end_date IS NOT NULL THEN
            FOR _calendar_id IN
                SELECT DISTINCT c.id
                FROM calendar c
                JOIN trip t ON t.period_calendar_id = c.id
                JOIN route r ON r.id = t.route_id
                WHERE r.line_version_id = NEW.id AND c.calendar_type = 'periode'
            LOOP
                PERFORM updateordeletecalendar(_calendar_id, NEW.start_date, NEW.end_date);
            END LOOP;
        END IF;
        RETURN NEW;
    END;
    $$;
COMMENT ON FUNCTION delete_overlaps_calendar() IS 'When a line_version is closed (i.e. end_date is filled), this function will clear trips which doesnt belong to it anymore because of their calendar dates.';

CREATE TRIGGER update_line_version AFTER UPDATE OF end_date ON line_version
FOR EACH ROW WHEN (OLD.end_date IS DISTINCT FROM NEW.end_date) EXECUTE PROCEDURE delete_overlaps_calendar();
