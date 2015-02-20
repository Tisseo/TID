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

	with connection.cursor() as cursor:
		try:
			query = u"SELECT insertline(%s, %s, %s, %s, %s)"
			cursor.execute(query, ('line1', 3, '1', 2, 3,))
			lines_id = cursor.fetchone()[0]
		except psycopg2.Error, e:
			print "query error: {0}\n{1}".format(query,e)
			sys.exit(1)
		
		try:
			query = u"SELECT InsertLineVersion(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
			cursor.execute(query, 
			(lines_id , 1, u"2014-01-31", None, u"2018-12-31", None, 'line version1', "forward", "backward", "bg_color", "bg_hexa_color", "fg_color", "fg_hexa_color", "carto_file", True, False, False, "comment", "depot", 2, "01",))
		except psycopg2.Error, e:
			print "query error: {0}\n{1}".format(query,e)
			sys.exit(1)
		

	print u'test OK'
	sys.exit(0)

if __name__ == "__main__":
	main()

	
#self.cursor.execute(u"SELECT InsertRoute(%s, %s, %s, %s, %s, %s)", (new_route['line_version_id'], new_route['way'], new_route['name'], new_route['direction'], new_route['name'], self.db_datas['datasource']['id'],))
#CREATE FUNCTION insertroute(_lvid integer, _way character varying, _name character varying, _direction character varying, _code character varying, _datasource integer) RETURNS void
#
#cursor.execute("SELECT InsertStopArea(%s, %s, %s)", (self.db_datas['cities'][stop['insee']].id, stop['stop_name'], self.db_datas['datasource']['id'],))
#CREATE FUNCTION insertstoparea(_city_id integer, _name character varying, _datasource integer) RETURNS void
#
#cursor.execute("SELECT InsertStop(%s, %s, %s, %s, %s, %s, %s, %s, %s)", (datetime.today().strftime("%d-%m-%Y"), stop['stop_name'], stop['stop_lon'], stop['stop_lat'], True, stop['stop_id'], stop['insee'], self.db_datas['datasource']['id'], self.srid,))
#CREATE FUNCTION insertstop(_date date, _name character varying, _x character varying, _y character varying, _access boolean, _code character varying, _insee character varying, _datasource integer, _srid integer default 27572) RETURNS void
#
#cursor.execute(u"SELECT InsertTrip(%s, %s, %s, %s, %s)", (trip['name'], trip['trip_code'], trip['route_code'], trip['line_version_id'], self.db_datas['datasource']['id'],))
#CREATE FUNCTION inserttrip(_name character varying, _tcode character varying, _rcode character varying, _lvid integer, _datasource integer) RETURNS void
#
#cursor.execute(u"SELECT InsertCalendar(%s, %s, %s, %s)", (calendar['service_id'], calendar['service_id'], self.db_datas['datasource']['id'], 1,))
#CREATE FUNCTION insertcalendar(_name character varying, _ccode character varying, _datasource integer, _calendar_type integer default 1) RETURNS integer
#
#cursor.execute(u"SELECT InsertCalendarLink(%s, %s)", (calendar['trip_id'], calendar_id,))
#CREATE FUNCTION insertcalendarlink(_trip_id integer, _period_calendar_id integer, _day_calendar_id integer default NULL) RETURNS integer
#
#cursor.execute(u"SELECT InsertCalendarElement(%s, %s, %s, %s, %s)", (calendar_id, first_date.strftime("%Y-%m-%d"), last_date.strftime("%Y-%m-%d"), interval, '+',))
#CREATE FUNCTION insertcalendarelement(_calendar_id integer, _start_date date, _end_date date, _interval integer default NULL, _positive character varying default NULL, _included_calendar_id integer default NULL) RETURNS integer
#
#
#cursor.execute(u"SELECT InsertRouteSection(%s, %s, %s, %s)", (rs['start_stop_id'], rs['end_stop_id'], rs['the_geom'], datetime.today().strftime("%d-%m-%Y"),))
#CREATE FUNCTION insertroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date) RETURNS void
#CREATE FUNCTION insertroutestopandstoptime(_rcode character varying, _tcode character varying, _scode character varying, _related_scode character varying, _lvid integer, _rank integer, _scheduled boolean, _hour integer, _is_first boolean, _is_last boolean) RETURNS void
#
#CREATE FUNCTION insertcalendar(_tcode character varying, _rcode character varying, _lvid integer, _name character varying, _date date, _datasource integer) RETURNS void
#CREATE FUNCTION insertpoi(_name character varying, _city_id integer, _type character varying, _priority integer, _datasource integer, _is_velo boolean, addresses address[]) RETURNS void
#
#CREATE FUNCTION updateroutesection(_start_stop_id integer, _end_stop_id integer, _the_geom character varying, _start_date date, _route_section_id integer, _end_date date) RETURNS void
#CREATE FUNCTION updatestop(_stop_history_id integer, _date date, _name character varying, _x character varying, _y character varying, _access boolean) RETURNS void

