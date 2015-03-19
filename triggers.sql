CREATE FUNCTION add_exceptions() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _exception_type record;
        _trip_calendar_id integer;
        _line_version_id integer;
        _auto_comment_id integer;
        _comment_id integer;
        _gc_pattern varchar(7);
        _tc_pattern varchar(7);
    BEGIN
        -- generic exception comment have to exist, create it if it doesn't
        SELECT id FROM comment WHERE label = 'zz' INTO _auto_comment_id;
        IF _auto_comment_id IS NULL THEN
            INSERT INTO comment(label, comment_text) VALUES('zz', 'Une exception a été détectée mais aucune action automatique na pu être effectuée.') RETURNING id INTO _auto_comment_id;
        END IF;

        -- build the grid_calendar pattern using new inserted glcmt grid_calendar_id value
        SELECT line_version_id, concat(cast(monday as char(1)), cast(tuesday as char(1)), cast(wednesday as char(1)), cast(thursday as char(1)), cast(friday as char(1)), cast(saturday as char(1)), cast(sunday as char(1))) FROM grid_calendar WHERE id = NEW.grid_calendar_id INTO _line_version_id, _gc_pattern;

        -- for each trip_calendar linked to the grid_mask_type from new inserted glcmt: build pattern and compare it to grid_calendar pattern
        FOR _trip_calendar_id, _tc_pattern IN SELECT id, concat(cast(monday as char(1)), cast(tuesday as char(1)), cast(wednesday as char(1)), cast(thursday as char(1)), cast(friday as char(1)), cast(saturday as char(1)), cast(sunday as char(1))) FROM trip_calendar WHERE grid_mask_type_id = NEW.grid_mask_type_id
        LOOP
            -- if the two patterns are different an exception is needed
            IF _gc_pattern != _tc_pattern THEN
                -- check the exception_type exists: no: create automatic comment | yes: create a comment with exception_type attributes
                SELECT * FROM exception_type WHERE grid_calendar_pattern = _gc_pattern AND trip_calendar_pattern = _tc_pattern INTO _exception_type;
                IF _exception_type IS NULL THEN
                    UPDATE trip SET comment_id = _auto_comment_id FROM trip AS t JOIN route AS r ON r.id = t.route_id JOIN trip_calendar AS tc ON tc.id = t.trip_calendar_id WHERE r.line_version_id = _line_version_id AND tc.id = _trip_calendar_id;
                ELSE
                    -- Check comment associated to exception_type already exists, if it doesn't create it
                    SELECT c.id FROM comment c WHERE c.comment_text = _exception_type.comment_text AND c.label = _exception_type.label INTO _comment_id;
                    IF _comment_id IS NULL THEN
                        INSERT INTO comment(label, comment_text) VALUES(_exception_type.label, _exception_type.comment_text) RETURNING id INTO _comment_id;
                    END IF;
                    UPDATE trip SET comment_id = _comment_id FROM trip AS t JOIN route AS r ON r.id = t.route_id JOIN trip_calendar AS tc ON tc.id = t.trip_calendar_id WHERE r.line_version_id = _line_version_id AND tc.id = _trip_calendar_id;
                END IF; 
            END IF;
       END LOOP;
       RETURN NEW;
    END;
    $$;
COMMENT ON FUNCTION add_exceptions() IS 'Detect exceptions and insert comments in trips according to multiple conditions. This function is triggered after insert/delete on table grid_link_calendar_mask_type.';

CREATE TRIGGER add_exceptions AFTER INSERT ON grid_link_calendar_mask_type
FOR EACH ROW EXECUTE PROCEDURE add_exceptions();
