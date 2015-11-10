# Travellers Information Datawarehouse

## Description

TID for Travellers Information Datawarehouse is a PostgeSQL database with a PostGIS extension. Its purpose is to store and transform public transport exploitation data into information dedicate to travellers. Tisséo provides 2 Symfony bundles for the management of TID database : [BoaBundle] and [PaonBundle].

TID covers:
 
- commercial line, different line offers and properties over time
- routes, trips, stop_time
- stop, stop area, stop history over time
- trip calendar, grid calendar
- POI, city, transport mode
- accessibility
- stops and routes shapes
- line schematic
- ...

## Requirements

- Postgresql 9.1+
- Postgis 2.1 (a script is available in order to install the extension)

## Installation (linux)

1. Set up [TID]:

```
git clone https://github.com/Tisseo/TID
```

2. Create database:

You have to set 5 parameters in the installation process :
- db: The database name
- owner: The database owner who can do everything with its content
- reader: The database reader who can only select on it
- password_owner: The password for owner user
- password_reader: The password for reader user

```Shell
# use your postgresql user in order to execute the sql files.
su postgres

psql -f TID/endiv_creation.sql -v db=endiv -v owner=endiv_owner -v password_owner=\'endiv_owner\' -v reader=endiv_reader -v password_reader=\'endiv_reader\'
psql -d endiv -f TID/endiv_rights.sql -v db=endiv -v owner=endiv_owner -v reader=endiv_reader
psql -d endiv -f TID/pgis_2.1.sql -v owner=endiv_owner
psql -U endiv_owner -d endiv -f TID/endiv.sql
psql -U endiv_owner -d endiv -f TID/stored_procedures.sql
psql -U endiv_owner -d endiv -f TID/triggers.sql
psql -U endiv_owner -d endiv -f TID/insert_initial_data.sql
psql -d endiv -f TID/grants.sql -v owner=endiv_owner -v reader=endiv_reader
```

## TODO

- Create an installer in order to simplify the installation process.

[PaonBundle]:https://github.com/Tisseo/PaonBundle
[BoaBundle]:https://github.com/Tisseo/BoaBundle
[TID]:https://github.com/Tisseo/TID
