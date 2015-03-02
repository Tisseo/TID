#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys
import argparse

POSTGRESQL_connection = u"host='localhost' port=5432 user='postgres' password='postgres'"
#DATABASE_NAME = u"endiv_jenkins"


def get_connection(database_name=''):
    try:
        if database_name=='':
            return psycopg2.connect(POSTGRESQL_connection)
        else:
            connection_string = POSTGRESQL_connection
            connection_string += u"dbname='{0}'".format(database_name)
            return psycopg2.connect(connection_string)
    except psycopg2.Error as e:
        print u"connection à la base de données impossible {0}".format(e)
        sys.exit(1)


def create_database(database_name):
    print u'creating database...'
    connection = get_connection()
    try:
        # should be psycopg2.extensions.ISOLATION_LEVEL_READ_COMMITTED(default)
        old_isolation_level = connection.isolation_level
        connection.set_isolation_level(0)
    
        cursor = connection.cursor()
        try:
            query = u"drop database if exists {0}".format(database_name)
            cursor.execute(query)
        except psycopg2.Error, e:
            print "query error: {0}\n{1}".format(query, e)
            sys.exit(1)
        try:
            query = u"create database {0}".format(database_name)
            cursor.execute(query)
        except psycopg2.Error, e:
            print "query error: {0}\n{1}".format(query,e)
            sys.exit(1)
    finally:
        if cursor:
            cursor.close()
        if connection:
            if old_isolation_level:
                connection.set_isolation_level(old_isolation_level)
            connection.close()


def create_data_structure(connection):
    print u'creating data structure(endiv.sql)...'
    cursor = connection.cursor()
    try:
        try:
            cursor.execute(open("../endiv.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while loading data structure: {0}".format(e)
            sys.exit(1)
    finally:
        if cursor:
            cursor.close()


def create_stored_procedures(connection):
    print u'creating stored procedures...'
    cursor = connection.cursor()
    try:
        try:
            cursor.execute(open("../stored_procedures.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while loading stored procedures: {0}".format(e)
            sys.exit(1)
    finally:
        if cursor:
            cursor.close()


def create_grants(connection):
    print u'creating grants...'
    cursor = connection.cursor()
    try:
        try:
            cursor.execute(open("../grants.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while creating grants: {0}".format(e)
            sys.exit(1)
    finally:
        if cursor:
            cursor.close()
            

def main():
    parser = argparse.ArgumentParser(description="Script de création d'une base de données ENDIV.")
    parser.add_argument("database", help="Spécifie le nom de la base de données")
    args = parser.parse_args()


    create_database(args.database)
    
    try:
        connection = get_connection(args.database)
        create_data_structure(connection)
        create_stored_procedures(connection)
        create_grants(connection)
    finally:
        if connection:
            connection.close()
    sys.exit(0)

if __name__ == "__main__":
    main()
