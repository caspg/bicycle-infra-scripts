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
  w/bicycle=yes \
  w/highway=footway \
  -o data/out.osm.pbf

osmconvert data/out.osm.pbf -o=data/out.o5m

osmfilter data/out.o5m \
  --ignore-dependencies \
  --keep-ways="( bicycle=yes and highway=footway ) or
               highway=cycleway or
               bicycle=designated or
               cycleway=lane or
               cycleway=track or
               cycleway:right=lane or
               cycleway:left=lane or
               cycleway:both=lane" \
  >data/out.osm

OSM_CONFIG_FILE=./osmconf.ini ogr2ogr -f GeoJSON data/out.geojson data/out.osm lines

tippecanoe -zg -o data/out.mbtiles -l default --drop-fraction-as-needed data/out.geojson
