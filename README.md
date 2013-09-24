SEPTA-iOS
=========

Source Code for the SEPTA iOS App


Quick Starter Guide:
===================

 * Fast method) Get a copy of the latest database from: http://www3.septa.org/hackathon/iOS/SEPTA.sqlite.gz
 
Then copy SEPTA.sqlite into the database/ directory in the repository.  (Note: you might need to create the database directory first.)

 
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
  

There's only one more step to go.


About the Images:
================

  * While the source code is licensed under the GPL, the images used by the app are not.  Replacements images have been made available to ensure the app can be compiled and run without issue.  When time permits, I can make less eye-piercing and happy replacements available.

The images can be found in this repository: https://github.com/septadev/SEPTA-iOS-beta-images.  Once downloaded, create an images directory in the SEPTA-iOS-beta repository and copy the files from SEPTA-iOS-beta-images into there.

Then launch iSEPTA.xcworkspace and enjoy.

