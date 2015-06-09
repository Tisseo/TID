CREATE USER endiv_owner WITH PASSWORD 'endiv_owner';
CREATE USER endiv_reader WITH PASSWORD 'endiv_reader';
CREATE DATABASE endiv WITH OWNER endiv_owner;
GRANT CONNECT ON DATABASE endiv TO endiv_reader;
GRANT CONNECT ON DATABASE endiv TO endiv_owner;
