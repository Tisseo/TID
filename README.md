TISSEO DATAWAREHOUSE
====================

1. Installation

    '''
    git clone https://github.com/Tisseo/TID 
    su postgres
    psql -f TID/endiv_creation.sql
    psql -U endiv_owner -d endiv -f TID/endiv_rights.sql
    psql -U endiv_owner -d endiv -f TID/endiv.sql
    psql -U endiv_owner -d endiv -f TID/stored_procedures.sql
    psql -U endiv_owner -d endiv -f TID/triggers.sql
    psql -U endiv_owner -d endiv -f TID/insert_initial_data.sql
    psql -U endiv_owner -d endiv -f TID/grants.sql
    '''

2. Documentation

    Coming soon.
