#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys


POSTGRESQL_connection = u"host='localhost' port=5432 user='postgres' password='postgres'"
DATABASE_NAME = u"endiv_jenkins"


def get_connection(connect_db=True):
    try:
        if connect_db:
            connection_string = POSTGRESQL_connection
            connection_string += u"dbname='{0}'".format(DATABASE_NAME)
            return psycopg2.connect(connection_string)
        else:
            return psycopg2.connect(POSTGRESQL_connection)
    except psycopg2.Error as e:
        print u"connection à la base de données impossible {0}".format(e)
        sys.exit(1)


def create_database():
    print u'creating database...'
    connection = get_connection(False)
    try:
        # should be psycopg2.extensions.ISOLATION_LEVEL_READ_COMMITTED(default)
        old_isolation_level = connection.isolation_level
        connection.set_isolation_level(0)
    
        with connection.cursor() as cursor:
            try:
                query = u"drop database if exists {0}".format(DATABASE_NAME)
                cursor.execute(query)
            except psycopg2.Error, e:
                print "query error: {0}\n{1}".format(query, e)
                sys.exit(1)
            try:
                query = u"create database {0}".format(DATABASE_NAME)
                cursor.execute(query)
            except psycopg2.Error, e:
                print "query error: {0}\n{1}".format(query,e)
                sys.exit(1)
    finally:
        if connection:
            if old_isolation_level:
                connection.set_isolation_level(old_isolation_level)
            connection.close()


def create_data_structure(connection):
    print u'creating data structure(endiv.sql)...'
    with connection.cursor() as cursor:
        try:
            cursor.execute(open("endiv.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while loading data structure: {0}".format(e)
            sys.exit(1)


def create_stored_procedures(connection):
    print u'creating stored procedures...'
    with connection.cursor() as cursor:
        try:
            cursor.execute(open("stored_procedures.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while loading stored procedures: {0}".format(e)
            sys.exit(1)


def create_grants(connection):
    print u'creating grants...'
    with connection.cursor() as cursor:
        try:
            cursor.execute(open("grants.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while creating grants: {0}".format(e)
            sys.exit(1)
            

def main():
    create_database()
    
    with get_connection() as connection:
        create_data_structure(connection)
        create_stored_procedures(connection)
        create_grants(connection)
    
    print u'tests OK'
    sys.exit(0)

if __name__ == "__main__":
    main()
