#!/bin/bash

# Informations about bicycle infrastructure tags:
# https://wiki.openstreetmap.org/wiki/Bicycle

rm -f data
mkdir data

# https://download.geofabrik.de/europe/poland.html
curl https://download.geofabrik.de/europe/poland-latest.osm.pbf -o input.osm.pbf

osmium tags-filter data/input.osm.pbf \
  w/highway=cycleway \
  w/bicycle=designated \
  w/cycleway=lane \
  w/cycleway=track \
  w/cycleway:right=lane \
  w/cycleway:left=lane \
  w/cycleway:both=lane \
  -o data/out.osm.pbf

OSM_CONFIG_FILE=./osmconf.ini ogr2ogr -f GeoJSON data/out.geojson data/out.osm.pbf lines

tippecanoe -zg -o data/out.mbtiles -l default --drop-fraction-as-needed data/out.geojson
