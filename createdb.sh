#!/bin/bash

if [ $(whoami) != "postgres" ]
then
	echo "Attention, le scrip doit être lancer avec l'utilisateur postgres"
	exit 1
fi

# Attention, le scrip doit être lancer avec l'utilisateur postgres
if [ ! -n "$1" ]
then
	echo "Attention, le scrip doit être lancer avec l'utilisateur postgres"
	echo "Usage: `basename $0` database_name"
	exit 1
fi

database_name=$1
base_dir=`dirname $0`

nb=`psql -A -t -q -c "select count(*) from pg_stat_activity where datname = '$database_name';"`
if [ $nb -gt 0 ]
then
	echo "Opération impossible, il y a des utilisateurs connectés à la base '$database_name'"
	exit 1
fi

dropdb $database_name
createdb $database_name
psql -f $base_dir/endiv.sql $database_name
psql -f $base_dir/endiv_rights.sql $database_name
psql -f $base_dir/stored_procedures.sql $database_name
psql -f $base_dir/insert_initial_data.sql $database_name

