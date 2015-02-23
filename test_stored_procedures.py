#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2
import sys
import logging
import logging.config


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
            #insertline(_number, _physical_mode_id, _line_code, _datasource, _priority)
            query = u"SELECT insertline(%s, %s, %s, %s, %s)"
            cursor.execute(query, ('line1', 3, '1', 2, 3,))
            lines_id = cursor.fetchone()[0]

            #insertlineversion(_line_id, _version, _start_date, _end_date, _planned_end_date, _child_line_id, _name, 
            #_forward_direction, _backward_direction, _bg_color, _bg_hexa_color, _fg_color, _fg_hexa_color, 
            #_carto_file, _accessibility, _air_conditioned, _certified, _comment, _depot, _datasource, _code)
            query = u"SELECT InsertLineVersion(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, " \
                    u"%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (lines_id, 1, u"2014-01-31", None, u"2018-12-31", None,
                                   'line version1', "forward", "backward", "rouge", "#FF0000", "blanc", "#FFFFFF",
                                   "carto_file", True, False, False, "comment", "depot", 2, "01",))
            line_version_id = cursor.fetchone()[0]

            #insertroute(_lvid, _way, _name, _direction, _code, _datasource)
            query = u"SELECT insertroute(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (line_version_id, u"Aller", u"route1", u"direction1", u"01", 2,))

            #insertstoparea(_city_id, _name, _datasource)
            query = u"SELECT InsertStopArea(%s, %s, %s)"
            cursor.execute(query, (1, u"StopArea1", 2,))

            #insertstop(_date, _name, _x, _y, _access, _code, _insee, _datasource, _srid)
            query = u"SELECT InsertStop(%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (u"2014-01-31", u"StopArea1", "526577.0", "1844787.0", True, u"01", u"31003", 2, 27572,))
            cursor.execute(u"select last_value from stop_id_seq")
            stop1_id = cursor.fetchone()[0]
            cursor.execute(query, (u"2014-02-01", u"StopArea1", "526580.0", "1844756.0", True, u"02", u"31003", 2, 27572,))
            cursor.execute(u"select last_value from stop_id_seq")
            stop2_id = cursor.fetchone()[0]

            #inserttrip(_name, _tcode, _rcode, _lvid, _datasource)
            query = u"SELECT InsertTrip(%s, %s, %s, %s, %s)"
            cursor.execute(query, (u"trip1", u"01", u"01", line_version_id, 2,))
            cursor.execute(u"select last_value from trip_id_seq")
            trip_id = cursor.fetchone()[0]

            #insertcalendar(_name, _ccode, _datasource, _calendar_type)
            query = u"SELECT InsertCalendar(%s, %s, %s, %s)"
            cursor.execute(query, (u"calendar1", u"01", 2, 1,))
            cursor.execute(u"select last_value from calendar_id_seq")
            calendar_id = cursor.fetchone()[0]

            #insertcalendarlink(_trip_id, _period_calendar_id, _day_calendar_id)
            query = u"SELECT InsertCalendarLink(%s, %s)"
            cursor.execute(query, (trip_id, calendar_id, None, ))

            #insertcalendarelement(_calendar_id, _start_date, _end_date, _interval, _positive, _included_calendar_id)
            query = u"SELECT InsertCalendarElement(%s, %s, %s, %s, %s)"
            cursor.execute(query, (calendar_id, u"2014-01-31", u"2014-01-31", None, u"+", None,))

            #insertroutesection(_start_stop_id, _end_stop_id, _the_geom, _start_date)
            query = u"SELECT InsertRouteSection(%s, %s, %s, %s)"
            cursor.execute(query, (stop1_id, stop2_id, u"0102000020670F00000500000078307B41A2213841544228BC6E3E4141438D6327C9213841657E629B523E4141E667B8A2E421384187DF0BB73C3E414179211D232222384146C5C9DC103E41415AE002613F22384106F61803FC3D4141", u"2014-01-31",))
            
        except psycopg2.Error, e:
            print "query error: {0}\n{1}".format(query, e)
            sys.exit(1)

    print u'test OK'
    sys.exit(0)

if __name__ == "__main__":
    main()



#insertroutestopandstoptime(_rcode, _tcode, _scode, _related_scode, _lvid, _rank, _scheduled, _hour, _is_first, _is_last)

#insertcalendar(_tcode, _rcode, _lvid, _name, _date, _datasource)
#insertpoi(_name, _city_id, _type, _priority, _datasource, _is_velo, addresses)

#updateroutesection(_start_stop_id, _end_stop_id, _the_geom, _start_date, _route_section_id, _end_date)
#updatestop(_stop_history_id, _date, _name, _x, _y, _access)

