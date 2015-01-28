-- Users
CREATE USER endiv_owner WITH PASSWORD 'endiv_owner';
CREATE USER endiv_reader WITH PASSWORD 'endiv_reader';

ALTER DATABASE endiv OWNER TO endiv_owner;
GRANT CONNECT ON DATABASE endiv TO endiv_reader;
GRANT CONNECT ON DATABASE endiv TO endiv_owner;
