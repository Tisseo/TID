#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys
import argparse

POSTGRESQL_connection = u"host='localhost' port=5432 user='postgres' password='postgres'"

def main():
    parser = argparse.ArgumentParser(description="Script d'insertion des données initiales d'une base ENDIV.")
    parser.add_argument("database", help="Spécifie le nom de la base de données")
    args = parser.parse_args()

    try:
        connection_string = POSTGRESQL_connection
        connection_string += u"dbname='{0}'".format(args.database)
        connection = psycopg2.connect(connection_string)
    except psycopg2.Error as e:
        print u"connection à la base de données impossible {0}".format(e)
        sys.exit(1)

    query = ''
    try:
        cursor = connection.cursor()
        try:
            cursor.execute(open("insert_initial_data.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while inserting initial datas: {0}".format(e)
            sys.exit(1)
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()
    print u'insertions OK'
    sys.exit(0)

if __name__ == "__main__":
    main()
