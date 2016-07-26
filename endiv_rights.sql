CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE SCHEMA pgis;
ALTER SCHEMA pgis OWNER TO :owner;

SET default_tablespace = '';
SET default_with_oids = false;

DO $$
BEGIN
   execute 'alter database ' || current_database() || ' SET search_path = public, pg_catalog, pgis';
END;
$$;

GRANT ALL PRIVILEGES ON DATABASE :db to :owner;
GRANT ALL PRIVILEGES ON SCHEMA public TO :owner;
GRANT USAGE ON SCHEMA public TO :reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO :reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO :reader;
