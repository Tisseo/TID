CREATE USER :owner WITH PASSWORD :password_owner;
CREATE USER :reader WITH PASSWORD :password_reader;
CREATE DATABASE :db WITH OWNER :owner;
GRANT CONNECT ON DATABASE :db TO :reader;
GRANT CONNECT ON DATABASE :db TO :owner;
