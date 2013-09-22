SEPTA-iOS
=========

Source Code for the SEPTA iOS App


Quick Starter Guide:
===================

 * Fast method) Get a copy of the latest database from: http://www3.septa.org/hackathon/iOS/SEPTA.sqlite.gz
 
Then copy SEPTA.sqlite into the database/ directory in the repository

 
-OR-


 * Manual method) Generate a new database with SEPTA's latest schedule.  
 
SEPTA GTFS data can be found here: http://www2.septa.org/developer/download.php .  Download the gtfs_public.zip, save it in the gtfs/ directory in the repository and uncompress it.  gtfs_public.zip contains two files: google_bus.zip and google_rail.zip.  

From the command line, cd into the gtfs/ directory and type the following:

  unzip google_bus.zip -d google_bus/
  unzip google_rail.zip -d google_rail/

Then to generate the database, use the following command (this will take between 5-10 minutes):

  perl create_database.pl


Note: this script uses the following libraries:

  - DBI;
  - POSIX;
  - GIS::Distance;


If you don't have them (or are not sure if you do), type

  perl -eshell -MCPAN   

(This might need to be run as sudo)

Then install each one individually be typing:

  install DBI
  install POSIX
  install GIS::Distance
  
  
Finally, copy the generated database into the database directory:

  cp SEPTA.sqlite ../database
  


About the Images:
================

  * While the source code is licensed under the GPL, the images used by the app are not.  As such, replacements images have been used to ensure the app can be compiled and run 

