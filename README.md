SEPTA-iOS
=========

Source Code for the SEPTA iOS App


Quick Starter Guide:
===================

 * Clone the repository 
 * Run install.sh (requires an Internet connection, and 5-10 minutes)
 * Launch iSEPTA.xcworkspace/ and start coding



Issues:
======

  * If install.sh has failed, there could be a couple of issues.  

  It runs the following scripts:
    - getImages.sh
    - getGTFS.sh
    - buildDB.sh

  getImages.sh pulls the images down from the SEPTA-iOS-beta-images github repository that this iOS project needs to work.  If you don't have an internet connection or git installed on your computer, this isn't going to work.

  getGTFS.sh uses wget to download the latest GTFS file from SEPTA.  Then the files are uncompressed and moved to the gtfs/ directory.

  buildDB.sh runs a perl script that takes the GTFS, throws out the data that isn't necessary and builds a sqlite database that the app needs to run.  Once the database, SEPTA.sqlite, has been generated, it is moved into the database/ directory.


Note: the Perl script (create_database.pl) uses the following libraries:

  - DBI;
  - POSIX;
  - GIS::Distance;


If you don't have them (or are not sure if you do), type the following:

  perl -eshell -MCPAN   

(This might need to be run as sudo)


Then install each one individually be typing:

  install DBI
  install POSIX
  install GIS::Distance
  
  

About the Images:
================

  * While the source code is licensed under the GPL v3, the images used by the app are not.  Replacements images have been made available to ensure the app can be compiled and run without issue.  When time permits, I can make less eye-piercing and happy replacements available.

The images can be found in this repository: https://github.com/septadev/SEPTA-iOS-beta-images.  Once downloaded, create an images directory in the SEPTA-iOS-beta repository and copy the files from SEPTA-iOS-beta-images into there.

Then launch iSEPTA.xcworkspace and enjoy.


Copyright and Trademark Notice
==============================

The full text can be found here: http://www.septa.org/site/copyright.html


Copyright Notice
----------------

The works of authorship contained in this World Wide Website, including but not limited to all design, text, sound recordings and images, are owned, except as otherwise expressly stated, by Southeastern Pennsylvania Transportation Authority ("SEPTA"). Except as otherwise expressly stated herein, they may not be copied, transmitted, displayed, performed, distributed (for compensation or otherwise), licensed, altered, framed, stored for subsequent use or otherwise used in whole or in part in any manner without SEPTA's prior written consent, except to the extent permitted by the Copyright Act of 1976 (17 U.S.C. ' 107), as amended, and then, only with notices of SEPTA's proprietary rights. This should be identified as "Copyright Southeastern Pennsylvania Transportation Authority. All Rights Reserved."


Trademark Notices
-----------------

The SEPTA Logo is a registered trademark of featured words or symbols, used to identify the source of its goods and services.
