#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys
import argparse


def create_database(database, dbname):
    try:
        connection = psycopg2.connect(database)
        isolation_level = connection.isolation_level
        connection.set_isolation_level(0)
        cursor = connection.cursor()
        try:
            query = u"DROP DATABASE IF EXISTS {0}".format(dbname)
            cursor.execute(query)
            query = u"CREATE DATABASE {0}".format(dbname)
            cursor.execute(query)
        except psycopg2.Error, e:
            print("Error: {0}\n{1}".format(query, e))
            sys.exit(1)
        finally:
            cursor.close()
    finally:
        connection.set_isolation_level(isolation_level)
        connection.close()


def main():
    parser = argparse.ArgumentParser(
        description="Script de création d'une base de données ENDIV."
    )
    parser.add_argument(
        "database",
        help="Spécifie la chaîne de requête vers la base de données"
    )
    args = parser.parse_args()

    dbname = args.database
    default_database = u"host='localhost' port=5432 user='postgres' password='postgres'"
    database = default_database + u" dbname='{0}'".format(dbname)

    print("Création de la base {0}".format(dbname))
    create_database(default_database, dbname)

    try:
        connection = psycopg2.connect(database)
    except psycopg2.Error as e:
        print(u"Connexion à la base de données impossible: {0}".format(e))
        sys.exit(1)

    files = ["endiv", "stored_procedures", "triggers", "grants"]

    cursor = connection.cursor()
    for f in files:
        print(u"lancement de {0}.sql...".format(f))
        try:
            cursor.execute("BEGIN")
            cursor.execute(open(f + ".sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print("Error: {0}".format(e))
            cursor.close()
            connection.close()
            sys.exit(1)

    cursor.close()
    connection.close()
    sys.exit(0)

if __name__ == "__main__":
    main()
