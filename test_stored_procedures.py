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
            print u"test function insertline ..."
            #insertline(_number, _physical_mode_id, _line_code, _datasource, _priority)
            query = u"SELECT insertline(%s, %s, %s, %s, %s)"
            cursor.execute(query, ('line1', 3, '1', 2, 3,))
            lines_id = cursor.fetchone()[0]

            #insertlineversion(_line_id, _version, _start_date, _end_date, _planned_end_date, _child_line_id, _name, 
            #_forward_direction, _backward_direction, _bg_color, _bg_hexa_color, _fg_color, _fg_hexa_color, 
            #_carto_file, _accessibility, _air_conditioned, _certified, _comment, _depot, _datasource, _code)
            print u"test function insertlineversion ..."
            query = u"SELECT InsertLineVersion(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, " \
                    u"%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (lines_id, 1, u"2014-01-31", None, u"2018-12-31", None,
                                   'line version1', "forward", "backward", "rouge", "#FF0000", "blanc", "#FFFFFF",
                                   "carto_file", True, False, False, "comment", "depot", 2, "01",))
            line_version_id = cursor.fetchone()[0]

            print u"test function insertroute ..."
            #insertroute(_lvid, _way, _name, _direction, _code, _datasource)
            query = u"SELECT insertroute(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (line_version_id, u"Aller", u"route1", u"direction1", u"01", 2,))

            print u"test function insertstoparea ..."
            #insertstoparea(_city_id, _name, _datasource)
            query = u"SELECT InsertStopArea(%s, %s, %s)"
            cursor.execute(query, (1, u"StopArea1", 2,))

            print u"test function insertstop ..."
            #insertstop(_date, _name, _x, _y, _access, _code, _insee, _datasource, _srid)
            query = u"SELECT InsertStop(%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (u"2014-01-31", u"StopArea1", u"525765.0", u"1843906.0", True, u"01", u"31003", 2, 27572,))
            cursor.execute(u"select last_value from stop_id_seq")
            stop1_id = cursor.fetchone()[0]
            cursor.execute(query, (u"2014-02-01", u"StopArea1", u"525764.0", u"1843916.0", True, u"02", u"31003", 2, 27572,))
            cursor.execute(u"select last_value from stop_id_seq")
            stop2_id = cursor.fetchone()[0]
            cursor.execute(query, (u"2014-02-02", u"StopArea1", u"525765.0", u"1843906.0", True, u"03", u"31003", 2, 27572,))
            cursor.execute(u"select last_value from stop_id_seq")
            stop3_id = cursor.fetchone()[0]
            cursor.execute(u"select last_value from stop_history_id_seq")
            stop_history_id = cursor.fetchone()[0]
            
            
            print u"test function updatestop ..."
            #updatestop(_stop_history_id, _date, _name, _x, _y, _access)
            query = u"SELECT updatestop(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (stop_history_id, u"2014-02-28", u"StopArea1", u"525731.0", u"1843959.0", False,))
            
            
            print u"test function inserttrip ..."
            #inserttrip(_name, _tcode, _rcode, _lvid, _datasource)
            query = u"SELECT InsertTrip(%s, %s, %s, %s, %s)"
            cursor.execute(query, (u"trip1", u"01", u"01", line_version_id, 2,))
            cursor.execute(u"select last_value from trip_id_seq")
            trip_id = cursor.fetchone()[0]

            print u"test function insertcalendar(_name, _ccode, _datasource, _calendar_type) ..."
            #insertcalendar(_name, _ccode, _datasource, _calendar_type)
            query = u"SELECT InsertCalendar(%s, %s, %s, %s)"
            cursor.execute(query, (u"calendar1", u"01", 2, 1,))
            cursor.execute(u"select last_value from calendar_id_seq")
            calendar_id = cursor.fetchone()[0]

            print u"test function insertcalendarlink ..."
            #insertcalendarlink(_trip_id, _period_calendar_id, _day_calendar_id)
            query = u"SELECT InsertCalendarLink(%s, %s, %s)"
            cursor.execute(query, (trip_id, calendar_id, None, ))

            print u"test function insertcalendarelement ..."
            #insertcalendarelement(_calendar_id, _start_date, _end_date, _interval, _positive, _included_calendar_id)
            query = u"SELECT InsertCalendarElement(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (calendar_id, u"2014-01-31", u"2014-01-31", None, u"+", None,))

            print u"test function insertroutesection ..."
            #insertroutesection(_start_stop_id, _end_stop_id, _the_geom, _start_date)
            query = u"SELECT InsertRouteSection(%s, %s, %s, %s)"
            cursor.execute(query, (stop1_id, stop2_id, u"LINESTRING(1571995.05248482 2268587.30153347,1571976.62924854 2268604.73100494,1571947.32201604 2268634.11366907,1571775.42880228 2268770.79682715,1571765.83546333 2268773.15336968,1571763.42570708 2268772.14089597,1571756.06490599 2268766.70187661,1571703.19363379 2268741.70339266)", u"2014-01-31",))
            
            cursor.execute(u"select last_value from route_section_id_seq")
            route_section_id = cursor.fetchone()[0]

            print u"test function updateroutesection ..."
            #updateroutesection(_start_stop_id, _end_stop_id, _the_geom, _start_date, _route_section_id, _end_date)
            query = u"SELECT updateroutesection(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (stop1_id, stop2_id, u"LINESTRING(1578146.40868818 2270727.99384361,1578147.31341277 2270727.85869324,1578158.66236149 2270730.98047967,1578166.97840882 2270741.90389785,1578179.33067102 2270757.26022192,1578216.32326444 2270794.40575811,1578238.70782503 2270817.19208892,1578251.05420268 2270829.7600617)", u"2015-01-31", route_section_id, u"2015-03-31",))

            print u"test function insertroutestopandstoptime ..."
            #insertroutestopandstoptime(_rcode, _tcode, _scode, _related_scode, _lvid, _rank, _scheduled, _hour, _is_first, _is_last)
            query = u"SELECT insertroutestopandstoptime(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (u"01", u"01", u"02", u"03", line_version_id, 0, True, 43200, True, True,))
            
            print u"test function insertcalendar(_tcode, _rcode, _lvid, _name, _date, _datasource) ..."
            #insertcalendar(_tcode, _rcode, _lvid, _name, _date, _datasource)
            query = u"SELECT insertcalendar(%s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (u"01", u"01", line_version_id, u"calendar2", u"2015-01-31", 2,))
            
            print u"test function insertpoi ..."
            #insertpoi(_name, _city_id, _type, _priority, _datasource, _is_velo, addresses)
            query = u"SELECT insertpoi(%s, %s, %s, %s, %s, %s, %s)"
            cursor.execute(query, (u"poi1", 1, u"poi_type1", 5, 2, False, [],))
        except psycopg2.Error, e:
            print "query error: {0}\n{1}".format(query, e)
            sys.exit(1)

    print u'tests OK'
    sys.exit(0)

if __name__ == "__main__":
    main()




