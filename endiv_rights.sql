-- wrapper de fichiers txt type csv utilisé pour les imports gtfs
CREATE EXTENSION IF NOT EXISTS file_fdw;
COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper which can be used to access data files in the (server)file system';
CREATE SERVER file_fdw_server FOREIGN DATA WRAPPER file_fdw;

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE SCHEMA pgis;
ALTER SCHEMA pgis OWNER TO endiv_owner;

SET default_tablespace = '';
SET default_with_oids = false;

DO $$
BEGIN
   execute 'alter database ' || current_database() || ' SET search_path = public, pg_catalog, pgis';
END;
$$;

GRANT ALL PRIVILEGES ON DATABASE endiv to endiv_owner;
GRANT ALL PRIVILEGES ON SCHEMA public TO endiv_owner;
GRANT USAGE ON SCHEMA public TO endiv_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO endiv_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO endiv_reader;
