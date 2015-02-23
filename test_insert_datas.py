#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys


POSTGRESQL_connection = u"host='localhost' port=5432 user='postgres' password='postgres' dbname='endiv_jenkins'"


def main():
    try:
        connection = psycopg2.connect(POSTGRESQL_connection)
    except psycopg2.Error as e:
        print u"connection à la base de données impossible {0}".format(e)
        sys.exit(1)

    query = ''
    with connection.cursor() as cursor:
        try:
            cursor.execute(open("insert_unit_test_data.sql", "r").read())
            cursor.execute("COMMIT")
        except psycopg2.Error, e:
            print "error while inserting datas: {0}".format(e)
            sys.exit(1)

    print u'insertions OK'
    sys.exit(0)

if __name__ == "__main__":
    main()




