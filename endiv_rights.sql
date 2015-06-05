-- Users
CREATE USER endiv_owner WITH PASSWORD 'endiv_owner';
CREATE USER endiv_reader WITH PASSWORD 'endiv_reader';

ALTER DATABASE endiv OWNER TO endiv_owner;
GRANT CONNECT ON DATABASE endiv TO endiv_reader;
GRANT CONNECT ON DATABASE endiv TO endiv_owner;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

-- wrapper de fichiers txt type csv utilisé pour les imports gtfs
CREATE EXTENSION IF NOT EXISTS file_fdw;
COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper which can be used to access data files in the (server)file system';
CREATE SERVER file_fdw_server FOREIGN DATA WRAPPER file_fdw;

CREATE EXTENSION IF NOT EXISTS unaccent;

SET default_tablespace = '';
SET default_with_oids = false;
SET search_path = public, pg_catalog, pgis;

DO $$
BEGIN
   execute 'alter database ' || current_database() || ' SET search_path = public, pg_catalog, pgis';
END;
$$;