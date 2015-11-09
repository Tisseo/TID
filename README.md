# Installation

```
git clone https://github.com/Tisseo/TID
su postgres
psql -f TID/endiv_creation.sql
psql -d endiv -f TID/endiv_rights.sql
psql -U endiv_owner -d endiv -f TID/endiv.sql
psql -U endiv_owner -d endiv -f TID/stored_procedures.sql
psql -U endiv_owner -d endiv -f TID/triggers.sql
psql -U endiv_owner -d endiv -f TID/insert_initial_data.sql
psql -d endiv -f TID/grants.sql 
```

# Description

TID for Travellers Information Datawarehouse is a PostgeSQL database with a PostGIS extension. Its purpose is to store and transform public transport exploitation data into information dedicate to travellers. Tisséo provides 2 Symfony bundles for the management of TID database : [BoaBundle](https://github.com/Tisseo/BoaBundle) and [PaonBundle](https://github.com/Tisseo/PaonBundle).

TID covers : 
- commercial line, different line offers and properties over time
- routes, trips, stop_time
- stop, stop area, stop history over time
- trip calendar, grid calendar
- POI, city, transport mode
- accessibility
- stops and routes shapes
- line schematic
- ...
