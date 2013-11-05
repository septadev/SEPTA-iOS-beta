#!/bin/bash

# Download the non-SEPTA copyrighted images to allow the project to build
./getImages.sh

# Download the latest GTFS information from www3.septa.org/hackathon
./getGTFS.sh

# Builds the database from the GTFS data and move it to the database directory
./buildDB.sh
