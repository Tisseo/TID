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
        
    integrity_error = False
    try:
        with connection.cursor() as cursor:
            with open('insert_integrity_errors.sql', 'r') as errors_files:
                for line in errors_files:
                    if line[0:1] != "--":
                        caught_exception = None
                        try:
                            cursor.execute(line)
                        except Exception as ex:
                            caught_exception = ex
                            integrity_error = (type(ex).__name__ == "IntegrityError")
                            cursor.execute("rollback")
                        if not integrity_error:
                            print "No integrity error occurred for line:'{0}'".format(line.replace("\n", ""))
                            if caught_exception:
                                print "Occurred error:\n{0}".format(caught_exception)
                            sys.exit(1)
        
        
    finally:
        if connection:
            connection.close()

    print u'integrity tests OK'
    sys.exit(0)

if __name__ == "__main__":
    main()




