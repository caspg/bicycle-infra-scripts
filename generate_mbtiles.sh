#!/bin/bash

# Informations about bicycle infrastructure tags:
# https://wiki.openstreetmap.org/wiki/Bicycle

rm -rf data
mkdir data

# https://download.geofabrik.de/europe/poland.html
curl https://download.geofabrik.de/europe/poland-latest.osm.pbf -o data/input.osm.pbf
# curl https://download.geofabrik.de/europe/poland/pomorskie-latest.osm.pbf -o data/input.osm.pbf

osmium tags-filter data/input.osm.pbf \
  w/highway=cycleway \
  w/bicycle=designated \
  w/cycleway=lane \
  w/cycleway=track \
  w/cycleway:right=lane \
  w/cycleway:left=lane \
  w/cycleway:both=lane \
  w/cycleway:right=track \
  w/cycleway:left=track \
  w/cycleway:both=track \
  w/bicycle=yes \
  w/highway=footway \
  -o data/out.osm.pbf

osmconvert data/out.osm.pbf -o=data/out.o5m

osmfilter data/out.o5m \
  --ignore-dependencies \
  --keep-ways="highway=cycleway or
               ( bicycle=yes and highway=footway ) or
               ( highway!=proposed and highway!=construction and bicycle=designated ) or
               ( highway!=proposed and highway!=construction and cycleway=track ) or
               ( highway!=proposed and highway!=construction and cycleway:*=track ) or
               ( highway!=proposed and highway!=construction and cycleway=lane ) or
               ( highway!=proposed and highway!=construction and cycleway:*=lane )" \
  >data/out.osm

OSM_CONFIG_FILE=./osmconf.ini ogr2ogr -f GeoJSON data/out.geojson data/out.osm lines

# `-z14`: Only generate zoom levels 0 through 14
tippecanoe -z14 -o data/out.mbtiles -l default --drop-fraction-as-needed data/out.geojson
