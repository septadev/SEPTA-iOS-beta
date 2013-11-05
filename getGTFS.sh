#!/bin/bash

wget http://www2.septa.org/developer/download.php -O gtfs_public.zip
unzip gtfs_public.zip
unzip google_rail.zip -d gtfs/google_rail
unzip google_bus.zip -d gtfs/google_bus
