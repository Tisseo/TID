#!/bin/sh

psql -d endiv -f ogive_schema_creation.sql -v owner=endiv_owner -v reader=endiv_reader
psql -d endiv -f ogive.sql -U endiv_owner
psql -d endiv -f ogive_grants.sql -v owner=endiv_owner -v reader=endiv_reader
