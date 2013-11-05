#!/bin/bash

cd gtfs
perl create_database.pl
mkdir ../database
mv SEPTA.sqlite ../database/
