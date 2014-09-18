#!/usr/bin/perl

# --==================
# --==
# --==  Purpose:
# --==    This script takes the GTFS text files stored in google_bus and google_rail directories and turns them
# --== into a database.  Of some of the things is does, moves only the pertinent fields into the DB, removes any
# --== redundant characters in said fields, ...
# --==
# --==    Each time the script is run, start fresh by unlinking the previous database.
# --==
# --==    Creates the following databases by default: SEPTArail.sqlite and SEPTAbus.sqlite
# --==
# --==================


# TODO:  Store multiple hours of operations for a route in a particular direction.  The LUCY routes come to mind

# --==  USE STATEMENTS  ==--
use strict;

use DBI;
use POSIX;

use GIS::Distance;

#use Data::Dumper;
#use feature 'say';

# --==  USE STATEMENTS  ==--


# --==  CONSTANTS  ==--
my $busDir  = "google_bus";  #Dependent on @dbfile name containing 'bus'
my $railDir = "google_rail"; #Dependent on @dbfile name containing 'rail'

my @tables = ("routes", "trips", "stops", "stop_times");  #createQuery needs to match up with this order and size
#my @dbfile = ("SEPTAbus.sqlite", "SEPTArail.sqlite");   # The DBs to create
my @dbfile = ("SEPTArail.sqlite", "SEPTAbus.sqlite");   # The DBs to create
my $dbFileName = "SEPTA.sqlite";
# --==  CONSTANTS  ==--



# --==  LEXICAL SYMBOLS AVAILABLE GLOBALLY  ==--
my $optRailTestOnly;
my $optBusTestOnly;

my $optOutputName;
my $optNoCompress;
my $optTimeFix;

# --==  LEXICAL SYMBOLS AVAILABLE GLOBALLY  ==--

# CREATE INDEX routeIDX on trips (route_id);
# CREATE INDEX tripIDX  on trips (trip_id);
# CREATE INDEX stopIDX  on stop_times (stop_id);




# --==  BEGIN HERE 644  ==--

mainLoop();

# --==  END HERE  ==--


# --==  SUBROUTINES  ==--


# --==  MAIN LOOP ==--
sub mainLoop
{
    
    unlink($dbFileName);
    
    foreach my $dbName (@dbfile)
    {
        populateGTFSTables($dbName);
        createIndex($dbName);
    }

    fixBSSNamingIssue();
    
    populateBusStopDirections();
    populateServiceHours();  # Uses the created stop_times_bus/rail and trips_bus/rail tables to create new table
    populateClosestStopMatch();
    populateStopIDRouteLookup();  # Used for Find Nearest Route
    populateGlensideCombined();
    repairBSOMFOArrivalTime();  # Fix issue where BSO and MFO have times over 2400.  This makes sense to service planning, but not in the context of the app
#    removeBadMFLStops();
    combineMFLStops();
    removeEmployeeOnlyStops();
    
    createMD5File();
    
#    createIndex();
    
}
# --==  MAIN LOOP ==--



# --==  SUBROUTINES  ==--
sub createIndex
{
    
    my $middlex;
    
    $_[0] =~ /SEPTA(.*?)\.sqlite/;
    $middlex = uc($1);
    
    print "CI - Creating index for $middlex\n";
    
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName\n\n";
    
    my $tripIDX  = "CREATE INDEX trip"  . $middlex . "IDX  on stop_times_$middlex (trip_id)";
    
    $dbh->do($tripIDX);
    
    $dbh->disconnect();
    
}


#
# Typical top two lines from google_bus
#

#==> routes.txt <==
# route_id,route_short_name,route_long_name,route_type,route_color,route_text_color,route_url
# 11270,1,Parx Casino to 54th-City,3,,,
#
# ==> trips.txt <==
# route_id,service_id,trip_id,trip_headsign,block_id,direction_id,shape_id
# 11219,1,3509653,"Chesterbrook",6170,0,144766
#
# ==> stops.txt <==
# stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station,zone_id,wheelchair_boarding
# 2,Ridge Av & Lincoln Dr  ,40.014986,-75.206826,,31032,1,0
#
# ==> stop_times.txt <==
# trip_id,arrival_time,departure_time,stop_id,stop_sequence
# 3509653,04:33:00,04:33:00,1721,1


#
# Typical top two lines from google_rail
#

#==> routes.txt <==
# route_id,route_short_name,route_long_name,route_desc,agency_id,route_type,route_color,route_text_color,route_url
# AIR,Airport Line,Airport Line,,SEPTA,2,91456C,FFFFFF,http://www.septa.org/schedules/rail/index.html
#
# ==> trips.txt <==
# route_id, service_id, trip_id, trip_headsign,block_id,trip_short_name, shape_id,direction_id
# AIR, S1, AIR_402_V5, Center City Philadelphia,402,402, AIRI_IB_1,0
#
# ==> stops.txt <==
# stop_id,stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url
# 90001,Cynwyd,Cynwyd Line,40.0066667,-75.2316667,2,
#
# ==> stop_times.txt <==
# trip_id, arrival_time, departure_time, stop_id, stop_sequence, pickup_type, drop_off_type
# AIR_402_V5, 05:09:00, 05:09:00, 90401, 1, 0, 0


# Important differences between the two:
#    route_id in bus is an INT while it's TEXT in rail.  Because sqlite is loosely typed, this doesn't cause a problem.
#    trip_id is in the same boat at route_id, a mix between INT and TEXT in bus and rail, respectively.
#    stop_id's are fortunately unique between the two, but there's no strict guarantee that this while always remain the case

# Because of this, I recommend:
#    * One common database, SEPTA.sqlite
#    * Seperate Bus and Rail tables

sub populateGTFSTables
{
    
    my $dbname = $_[0];
    
    return if ( $dbname =~ /rail/ && $optBusTestOnly );
    return if ( $dbname =~ /bus/ && $optRailTestOnly );
    
    my %busOperationHours = {};
    
    my $LCV;
    my $filename;
    
    my @tables = ("routes", "trips", "stops", "stop_times");  #createQuery needs to match up with this order and size
    
    #Field names should (better!) match up with that in the GTFS data files or the script will just crash
    #Note: there is one for each database because the header files between the two are different for the same file name

    my %createQuery = (
    'SEPTAbus.sqlite' =>    [
    "CREATE TABLE REPLACEME(route_id INT, route_short_name TEXT, route_long_name TEXT, route_type INT)",
    "CREATE TABLE REPLACEME(route_id INT, service_id INT, trip_id INT PRIMARY KEY, direction_id INT, block_id TEXT)",
    "CREATE TABLE REPLACEME(stop_id INT PRIMARY KEY , stop_name TEXT, stop_lat TEXT, stop_lon TEXT, wheelchair_boarding INT)",
    "CREATE TABLE REPLACEME(trip_id INT, arrival_time INT, stop_id INT, stop_sequence INT)",
    ],
    'SEPTArail.sqlite' =>   [
    "CREATE TABLE REPLACEME(route_id TEXT, route_short_name TEXT, route_long_name TEXT, route_type INT)",
    "CREATE TABLE REPLACEME(route_id TEXT, service_id INTEGER, trip_id TEXT, direction_id INT, block_id TEXT)",
    "CREATE TABLE REPLACEME(stop_id INT PRIMARY KEY , stop_name TEXT, stop_lat TEXT, stop_lon TEXT, wheelchair_boarding INT)",
    "CREATE TABLE REPLACEME(trip_id TEXT, arrival_time INT, stop_id INT, stop_sequence INT)",
#    "CREATE TABLE REPLACEME(route_id INTEGER, route_short_name TEXT, route_long_name TEXT, route_type INTEGER)",
#    "CREATE TABLE REPLACEME(route_id INTEGER, service_id INTEGER, trip_id INTEGER, trip_short_name INTEGER, direction_id INTEGER, block_id TEXT)",
#    "CREATE TABLE REPLACEME(stop_id INTEGER, stop_name TEXT, stop_lat TEXT, stop_lon TEXT, zone_id TEXT)",
#    "CREATE TABLE REPLACEME(trip_id INT, arrival_time TEXT, stop_id INT, stop_sequence INT, pickup_type INT, drop_off_type INT)",
    ]
    );
    
    
    # --======
    # --== STOP_TIMES.TXT
    # --==    arrival_time = 12:01:00       =>  12:01
    # --==    trip_id      = WAR_4331_V5    =>  _4331_  (WAR is not needed; neither is V5);  Rail Only!  (Need to ensure trips.txt gets updated as well.)
    # --==    departure_time is not even being added
    # --======
    
    # --======
    # --== TRIPS.TXT
    # --==    trip_id     = WAR_4331_V5     => _4331_
    # --==    trip_headsign is not needed; if it every is needed, it gets it's own damn table!
    # --==    trip_short_name and block_id seems to be the same; trip_short_name can go away
    # --==
    # --======
    
    
    #
    # --==    Database will contain just 4*2 tables: routes, trips, stops and stop_times.  Shapes won't do what we need it too.  Plenty of redundant points
    # --==  limited enviroment.  Need to minimize the number of coordinates to map.
    #

    
    # --==   Remove old database and start anew!  ==--
#    unlink($dbname);
    
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbname, filename: $filename and line number: $.\n\n";
    
    
    # These two lines help with speeding up the SQLite inserts
    $dbh->do('PRAGMA synchronous = 0');
    $dbh->do('PRAGMA cache_size = 200000');

    
    my %serviceConverter = ();
    my %serviceDays = ();
    my %holidays = ();
    
    my %tripsUniqueIDs = {};
    my $numberOfTrips;
    my $tripUniqueValue = 1;
    my $tripMaxCharacters;
    
    my %avoidDuplicateStopTimes = {};
    my $duplicateFound = 0;
    
    my $suffix;
    
    my $routeHashRef;
    populateRoutesHash ( fullPathFor("routes.txt"),  $routeHashRef);
    
    
    {
     
        $dbname =~ /SEPTA(.*?).sqlite/;
        $suffix = $1;
        
    # --==  Pull In Calendar Data  ==--
        $filename = "$busDir/calendar.txt" if ( $dbname =~ /bus/ );
        $filename = "$railDir/calendar.txt" if ( $dbname =~ /rail/ );
        
        open SERVICE, $filename or die "Could not open $filename.  $!\n";
        
        my $headersFromFile = <SERVICE>;
        my @headerArrayFromFile = split(/,/, $headersFromFile);
        my @headersWeCareAbout = ("service_id","monday","tuesday","wednesday","thursday","friday","saturday","sunday","start_date","end_date");
        my $columns = {};
        
        returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);


        my $uniqueID = 1;
        my @dateArr;

        $dbh->do("CREATE TABLE calendar_$suffix (service_id INT, days TEXT, start TEXT, end TEXT)");
        
        while (<SERVICE>)
        {
            my @serviceArr = split(/,/);
        
            my $service_id = trim($serviceArr[ $columns->{service_id} ]);
            
            my $monday = $serviceArr[ $columns->{monday} ];
            my $tuesday = $serviceArr[ $columns->{tuesday} ];
            my $wednesday = $serviceArr[ $columns->{wednesday} ];
            my $thursday = $serviceArr[ $columns->{thursday} ];
            
            my $friday   = $serviceArr[ $columns->{friday} ];
            my $saturday = $serviceArr[ $columns->{saturday} ];
            my $sunday   = $serviceArr[ $columns->{sunday} ];
            
            my $start    = $serviceArr[ $columns->{start_date} ];
            my $end      = trim($serviceArr[ $columns->{end_date} ]);
#            $serviceConverter{ $service_id } = $sunday*(2**6) + $monday*(2**5) + $tuesday*(2**4) + $wednesday*(2**3) + $thursday*(2**2) + $friday*2 + $saturday;
            
            $serviceDays{ $service_id } = $sunday*(2**6) + $monday*(2**5) + $tuesday*(2**4) + $wednesday*(2**3) + $thursday*(2**2) + $friday*2 + $saturday;
            $serviceConverter{ $service_id } = $uniqueID++;  # Used to modify the service_id value in trips
#            $serviceConverter{ $service_id } = $service_id;
            
            print "INSERT INTO calendar_$suffix VALUES ($serviceConverter{ $service_id }, $serviceDays{ $service_id }, $start, $end)\n";
            $dbh->do("INSERT INTO calendar_$suffix VALUES ($serviceConverter{ $service_id }, $serviceDays{ $service_id }, $start, $end)");
            
#            my $dateHash = {"start" => $serviceArr[ $columns->{start_date} ], "end" => $serviceArr[ $columns->{end_date} ], "service" => service_id, "days" => $serviceConverter{ $service_id } };
#            push(@dateArr, $dateHash);

        }
        
        close SERVICE;

#        service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
#        S1,1,1,1,1,1,0,0,20131215,20140406
#        S2,0,0,0,0,0,1,0,20131215,20140406
#        S3,0,0,0,0,0,0,1,20131215,20140406
#        S4,0,0,0,0,1,0,0,20131215,20140406
#        S5,0,0,1,0,0,0,0,20131225,20131225

#        S1,1,1,1,1,1,0,0,20131215,20131224
#        S1,1,1,1,1,1,0,0,20131226,20140406
        

#        S5,0,0,1,0,0,0,0,20131225,20131225
#        S1,1,1,1,1,1,0,0,20131215,20140406
#        S2,0,0,0,0,0,1,0,20131215,20140406
#        S3,0,0,0,0,0,0,1,20131215,20140406
#        S4,0,0,0,0,1,0,0,20131215,20140406

        
        
        
        
        
        $filename = "$busDir/calendar_dates.txt" if ( $dbname =~ /bus/ );
        $filename = "$railDir/calendar_dates.txt" if ( $dbname =~ /rail/ );
        
        open HOLIDAY, $filename or die "Could not open $filename.  $!\n";
        
        $headersFromFile = <HOLIDAY>;
        @headerArrayFromFile = split(/,/, $headersFromFile);
        @headersWeCareAbout = ("service_id","date","exception_type");
        
        $columns = {};
        
        returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
        $dbh->do("CREATE TABLE holiday_$suffix (service_id INT, date TEXT)");
        while (<HOLIDAY>)
        {
            my @holidayArr = split(/,/);
            
            my $service_id     = $holidayArr[ $columns->{service_id} ];
            my $date           = $holidayArr[ $columns->{date} ];
            my $exception_type = $holidayArr[ $columns->{exception_type} ];
            
            if ( $exception_type == 1 )
            {
                $holidays{$date} = $serviceConverter{ $service_id };
                print "INSERT INTO holiday_$suffix VALUES ($holidays{$date}, $date)\n";
                $dbh->do("INSERT INTO holiday_$suffix VALUES ($holidays{$date}, $date)");
            }
            
        }
        
#        $dbh->do("CREATE TABLE service_$suffix (service_id INT, days INT)");
#        foreach my $key (keys %serviceConverter)
#        {
#            $dbh->do("INSERT INTO service_$suffix VALUES ($serviceConverter{ $key }, $serviceDays{ $key })");
#        }
        
        close HOLIDAY;
        
    }
    
    
    # Rewrite Attempt 1
    #   Load routes, trips, stop_times, stops once.  Use them throughout the life of this script.
    
    
    
    # --==  Build the tables  ==--
    # --==  my @tables = ("routes", "trips", "stops", "stop_times");  #createQuery needs to match up with this order and size  ==--
    for ($LCV = 0; $LCV <= $#tables; $LCV++)
    {
        
        # Should only be temporary.  Until this data makes its way into the rail GTFS
        # If the Rail_ADA.csv does not exist, $adaStopNames should be blank and all the rail wheelchair_boarding fields should be 0
        my %adaStopNames;
        if ( ( $tables[$LCV] =~ "stops" ) && ( $dbname =~ /rail/ ) && ( -e "Rail_ADA.csv" ) )
        {
            # Open Rail_ADA.csv
            open ADA, "Rail_ADA.csv" or die "GTFS - Unable to open Rail_ADA.csv, err: $!\n";
            
            
            while (<ADA>)
            {
                my @array = split(/,/);
                $adaStopNames{$array[0]} = $array[1];
            }
            
            close ADA;
        }
        

        # suffix will either be "rail" or "bus"
        $dbname =~ /SEPTA(.*?).sqlite/;
        $suffix = $1;
        
        #  Update the createTable statement with the appropriate table
        $createQuery{$dbname}[$LCV] =~ s/REPLACEME/$tables[$LCV]_$suffix/;

        if ( !$createQuery{ $dbname }[$LCV] ) 
        {
            print "GTFS - createQuery for $tables[$LCV]_$suffix index $LCV is empty.\n";
        }  # if ( !$createQuery{ $dbname }[$LCV] )
        else
        {
            #  Now create the table
            print "GTFS - $createQuery{$dbname}[$LCV]\n";
            $dbh->do($createQuery{$dbname}[$LCV]);            
        }
        
        

        $filename = "$busDir/$tables[$LCV].txt" if ( $dbname =~ /bus/ );
        $filename = "$railDir/$tables[$LCV].txt" if ( $dbname =~ /rail/ );

#        if ( $tables[$LCV] =~ /trips/ )
#        {
#            %tripsUniqueIDs = {};
#            $tripUniqueValue = 0;
#            $numberOfTrips = `wc -l $filename`;
#            $numberOfTrips =~ /^\s*(\d+)/;
#            $numberOfTrips = $1;
#
#            $tripMaxCharacters = ceil(log($numberOfTrips)/log(36));
#            $tripUniqueValue = "0" x 3;
#        }
        
        if ( $tables[$LCV] eq "stop_times" )
        {
            print "Break";
        }
        
        
        # Open FILE specified in $filename and immediately store the first line.  This will contain the column data for that file
        open FILE, $filename or die "GTFS - Unable to open $tables[$LCV], err: $!\n";
        my $headersFromFile = <FILE>;
        my @headerArrayFromFile = split(/,/, $headersFromFile);
        
        
        # The fields we're interested in just so happen to be in the createQuery hash, grab 'em.
        $createQuery{$dbname}[$LCV] =~ /\((.*)\)/;
        my $matches = $1;
        
        #Uncomment the conditional statement below to swap departure_times with arrival_times
        #if ( $tables[$LCV] eq "stop_times" )
        #{
        #    $matches =~ s/arrival_time/departure_time/;
        #}
        my @unfilteredFields = split(/,/, $matches);  # $1 = "route_type INTEGER, route_id INTEGER, etc."
        
        
        # Hacky way of fitting wheelchair_boarding information into the GTFS data
        if ( ( $tables[$LCV] =~ "stops" ) && ( $dbname =~ /rail/ ) )
        {
            push(@headerArrayFromFile,"wheelchair_boarding");
        }
        
        
        foreach my $field (@unfilteredFields)
        {
            trim($field);
            $field =~ s/ .*//;  # All that's left now is something like "route_type INTEGER".  Remove everything from the first space onward
        } # foreach my $field (@unfilteredFields)
        
        my $columns = {};
        
        # Populates $columns with the locations of the fields we care about
        returnColumnsWeCareAbout(\@unfilteredFields, \@headerArrayFromFile, $columns);
        
        
        # These two lines are for displaying the data being writting into the SQLite database
        my $numberOfLines = `wc -l $filename`;  # Isn't there a native Perl variable to get the number of lines in a file?
        my $printAgain = ceil($numberOfLines / 100);
        
        $dbh->do("BEGIN"); #The final stage of the SQLite database, BEGIN before the loop, COMMIT after it
        
        my $questStr = "?," x ($#unfilteredFields+1);
        chop($questStr);
        
        my $sth = $dbh->prepare("INSERT INTO $tables[$LCV]_$suffix VALUES ($questStr)");

        # GC Glenside Combined Glenside Combined  SEPTA 2 91456C FFFFFF http://www.septa.org/schedules/rail/index.html
        
        my @valueArr;
        while (<FILE>)
        {
            
            my @arr = split(/,/);
            
            foreach my $field (@arr)
            {
                trim($field);
            }
            
            
            # Do special formatting for the specific files in here, in needed.
            if ( $filename =~ /stops.txt/ )
            {
                # wheelchair_boarding
                # if ( $dbname =~ /bus/ );
                if ( $adaStopNames{ $arr[$columns->{stop_id}] } )
                {
                    push(@arr,"1");
                }
                else
                {
                    push(@arr,"0");
                }
                
            }
            elsif ( $filename =~ /trips.txt/ )
            {
                
                # Get current trip_id
#                my $tripID = $arr[ $columns->{trip_id} ];
#                
#                # Store the tripID and what value we're replacing it with; this will be then used in stop_times
#                $tripsUniqueIDs{$tripID} = $tripUniqueValue;
#
#                # Replace the tripID with the new value
#                $arr[ $columns->{trip_id} ] = $tripUniqueValue;
#
#                # Increment the tripUniqueValue according to the rules setup in incrementUniqueValue
#                incrementUniqueValue($tripUniqueValue);
#                print "Replacing trip_id $tripID with $tripUniqueValue\n";
                
                # --==  trip_id processing  ==--
                $arr[$columns->{service_id}] = $serviceConverter{ $arr[$columns->{service_id}] };  # Replace old service_id with a power of two version
                
                my $tripID = $arr[ $columns->{trip_id} ];
                if ( $tripID =~ /(_\w+.*)/ )
                {
                    $tripID = $1;
                    $arr[ $columns->{trip_id} ] = $tripID;
                }
                
                if ( $suffix eq "bus" )
                {
                    $arr[ $columns->{route_id} ] = $routeHashRef->{$arr[0]}{route_short_name};  # Replace route_id with route_short_name
                }
                
            }
            elsif ( $filename =~ /stop_times.txt/ )
            {
            
                # --==  arrival_time processing  ==--
                my $arrivalTime = $arr[ $columns->{arrival_time} ];

                # This next statement is used to fix the GTFS rail.  Until the Rail gets a Night Owl server, that is.  Then there's no
                #   way to differentiate between a timing screwup (e.g. 01:00:00 is used when 25:00:00 should have been to indicate
                #   still part of the same day schedule) and a legitimate midnight, next day, time.
                repairArrivalTime( \$arrivalTime ) if ( $dbname =~ /rail/ );
#                repairBSOMFOArrivalTime( \$arrivalTime ) if ( $dbname =~ /bus/ );
                
                #Convert 25:01:00 to 2501
                $arrivalTime =~ /^\s*(\d+):(\d+)/;
#                print "Hour: $1, Min: $2\n";
#                $arrivalTime =~ s/:\d\d$//;  # Remove the last ":00" bit
#                $arr[ $columns->{arrival_time} ] = $arrivalTime;
                $arr[ $columns->{arrival_time} ] = $1 . $2;
                
                # --==  trip_id processing  ==--
                my $tripID = $arr[ $columns->{trip_id} ];
                if ( $tripID =~ /(_\w+.*)/ )
                {
                    $tripID = $1;
                    $arr[ $columns->{trip_id} ] = $tripID;
                }
                

                # Check if we replaced the trip_id with a new value (this should have been done above when $filename was trips.txt)
#                if ( $tripsUniqueIDs{$tripID} )
#                {
                    # If the trip_id was replaced, replace it here as well
#                    $arr[ $columns->{trip_id} ] = $tripsUniqueIDs{$tripID};
#                }
                
                my $seq = $arr[ $columns->{stop_sequence} ];
                
                if ( $avoidDuplicateStopTimes{$tripID} =~ /\b$seq,/ )
                {
                    $duplicateFound = 1;
                    my $message = sprintf("GTFS - Duplicate stop sequence at %3s in %8s found in %s\n", $seq, $tripID, $avoidDuplicateStopTimes{$tripID} );
                    print $message;
                }
                else
                {
                    $avoidDuplicateStopTimes{$tripID} .= $seq . ",";
                }
                
                
                
            }
            elsif ( $filename =~ /route.txt/ )
            {
                
            }
            
            
            @valueArr = ();
            foreach my $key (@unfilteredFields)
            {
                push(@valueArr, $arr[ $columns->{$key} ]);
            }
            
            $sth->execute( @valueArr ) if (!$duplicateFound);
            $duplicateFound = 0;
            
            #This isn't necessary but a nice little verification that the script is working and a quick glimpse
            #  at the data that is being written into it.  As long as $printAgain is $numberOfLines / 100, it
            #  also doubles as a progress meter.  For files with line numbers above 1000, every printout is
            #  roughly 1% of the file read in and written into the database
            
            if ( ( $. % $printAgain ) == 0 )
            {
                my $string = join(", ", @valueArr);
                print "GTFS: $. - $dbFileName -- INSERT INTO $tables[$LCV]_$suffix VALUES( $string )\n";
            }
            
        } # while (<FILE>) -- read all the lines from each text files listed in @tables.
        
        
        if ( $dbname =~ /rail/ && $filename =~ /routes.txt/ )
        {
            my @arr = split(/,/, "GC,Glenside Combined,Glenside Combined,,SEPTA,2,91456C,FFFFFF,http://www.septa.org/schedules/rail/index.html");
            
            @valueArr = ();
            foreach my $key (@unfilteredFields)
            {
                push(@valueArr, $arr[ $columns->{$key} ]);
            }
            
            $sth->execute( @valueArr )
        }
        
        
        close FILE;
        $dbh->do("COMMIT");
        
        
    } # for ($LCV = 0; $LCV <= $#tables; $LCV++)
    
    $dbh->disconnect();
    
} # sub populateGTFSTables


sub incrementUniqueValue
{

    # Addition Rules:
    #   "A0" + 1 = "A1"
    #   "AY" + 1 = "AZ"
    #   "AZ" + 1 = "B0"

#    print "Incrementing value: $_[0]";
#    incrementStringValue($_[0]);
    incrementNumericValue($_[0]);
#    print " returns: $_[0]\n"

}

sub incrementNumericValue
{
    $_[0]++;
}

sub incrementStringValue
{
    my $value = $_[0];
    my @arr = split(//, $value);
    
    # Convert to ASCII
    # '0' is 48, '9' is 57
    # 'A' is 65, 'Z' is 90
    
    my $carryOut = 0;
    foreach my $char (reverse @arr)
    {
        
        $carryOut = 0;
        my $ord = ord($char) + 1;
        
        # Only carryOut when $ord > 90!
        $ord = 65 if ( $ord == 58 );
        
        if ( $ord == 91 )
        {
            $ord = 48;
            $carryOut = 1;
        }
        
        $char = chr($ord);
        
        last if ( !$carryOut );
        
    }
    
    unshift(@arr,"1") if ( $carryOut );
    
    $_[0] = join('', @arr);
}




#sub repairBSOMFOArrivalTime
#{
#
#    my $time = ${$_[0]};
#    my $mins = 0;
#    my @values = split(/:/, $time);
#    
#    $mins = $values[0] * 60 + $values[1];
#
#    if ( $mins > (10 * 60) )  # If $mins is greater than 10 hrs
#    {
#        $values[0] -= 24;
#        ${$_[0]} = join(":", @values);
#        print "GTFS - Time was: $time, now is: ${$_[0]}\n";
#    }
#    
#}


sub repairArrivalTime
{
    
    my $time = ${$_[0]};
    my $mins = 0;
    my @values = split(/:/, $time);
    
    $mins = $values[0] * 60 + $values[1];
    
    if ( $mins < 180 )
    {
#        my @newTimes = split(/:/, $time);
#        $newTimes[0] = $newTimes[0] + 24;
#        $_[0] =  join(":", @newTimes);
        $values[0] += 24;
        ${$_[0]} = join(":", @values);
        print "GTFS - Time was: $time, now is: ${$_[0]}\n";
    }
    
}

sub trim
{
    $_[0] =~ s/^\s*//;
    $_[0] =~ s/\s*$//;
    return $_[0];
}


sub returnColumnsWeCareAbout
{
    
    my @headersWeCareAbout = @{ $_[0] };
    my @headerArrayFromFile = @{ $_[1] };
    my $columns = $_[2];
    
    my $count;
    
    foreach my $ourHeader (@headersWeCareAbout)  # Cycle through all our headers
    {
        $count = 0;
        foreach my $fileHeader (@headerArrayFromFile)  # Cycle through all headers from the file
        {
            if ( $fileHeader =~ /$ourHeader/ )  # If there is a match store it.
            {
                $columns->{ $ourHeader } = $count;  # Store information in a hash.  E.g. $columns{ route_id } = 3
                last;
            }
            $count++;
        }
    }
    
}
#returnColumnsWeCareAbout(@headersWeCareAbout, @headerArrayFromFile, %columns);

sub populateBusStopDirections
{
    
    my $dbname = $_[0];
    
    if ( $dbname =~ /rail/ )
    {
        return;  # This table is only meant for Buses, Trollys, NHSL, BSS/BSO, and MFL/MFO
    }
    
    my $filename = "direction.txt";
#    unless ( -e $filename )
#    {
#        return;
##        print "Found $filename";
#    }
    
    my $data;
    if ( -e $filename )
    {
        $data = `php53 direction.txt`;
        $data =~ s/BSS,/BSL,/g;
    }
    elsif ( -e "busStopDirections.csv" )
    {
        open DATA, "busStopDirections.csv" or die "Unable to open busStopDirections.csv";
        while (<DATA>)
        {
            $data .= $_;
        }
        close DATA;
    }
    else
    {
        return;
    }
    
    
#    my $data = `php53 direction.txt`;
    if ( !$data )
    {
        print " *** WARNING: Unable to create php53 direction.txt\n";
        return;  # Might be better to create the table and leave it empty.
    }
    
    my @data = split(/\n/, $data);
    
    my $columnInfo = shift(@data);
    my $header = shift(@data);
    my @header = split(/,/, $header);
    
    my %columnInfo = ();
    my @columnInfo = split(/,/, $columnInfo);
    
    foreach my $column (@columnInfo)
    {
        my @name = split(/:/, $column);
        
        # Conversion between SQL Server data types to SQLite data types
        $name[1] =~ s/varchar/TEXT/;
        $name[1] =~ s/int/INTEGER/;
        
        $columnInfo{$name[0]} = $name[1];  # $column{Route}, $column{Direction}
    }
    
    
    # --==  Connect to DB  ==--    
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbname.\n\n";
    
    my $tableName = "bus_stop_directions";
    $dbh->do("DROP TABLE IF EXISTS $tableName");
    
    my $insert = "INSERT INTO $tableName (";
    my $query = "CREATE TABLE $tableName (";
    foreach my $name (@header)
    {
        $query .= "$name $columnInfo{$name},";
        $insert .= "$name,";
    }
    chop($query);
    $query .= ")";
    
    chop($insert);
    my $questionMarks = "?," x ($#header+1);
    chop($questionMarks);
    $insert .= ") VALUES ($questionMarks)";
    
    $dbh->do($query);
    my $sth = $dbh->prepare($insert);
    
    print "\n\nBSD: Creating new table called $tableName.\n";
    foreach my $line (@data)
    {
        my @fields = split(/,/, $line);
        #        print "@fields";
        $sth->execute(@fields);
    }
    
    $dbh->disconnect();
    print "BSD: table was created and populated.\n\n";
    
    
} # sub populateBusStopDirections


sub determineServiceHours
{

    # Get the start and stop times of every trip.
    # Loop through all times for a route to find any gaps in the schedule
    
    # Trip 1: 02:00 - 08:00, 06:00 - 12:00, 14:00 - 18:00   (Gap: 12:00 to 14:00)
    #  * sort by earliest time
    #  * if the start of the next time is between the start/end of the master, set the new max as the greater of the old and new
    #  * if the start of the next time is not between, this is a gap (for now).  How to track gaps?
    
    # Array of start and end points?
    # Object 1 - start, end.
    # Object 2 - start, end.
    
}


sub populateServiceHours
{
    
    my $dbname = $_[0];

    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbname.\n\n";
    
    
#    my $selectCreate = "CREATE TABLE serviceHours AS SELECT a.route_id, a.min, b.max FROM (SELECT route_id, MIN(arrival_time) min FROM stop_times_bus JOIN trips_bus ON trips_bus.trip_id=stop_times_bus.trip_id GROUP BY route_id) a, (SELECT route_id, MAX(arrival_time) max FROM stop_times_bus JOIN trips_bus ON trips_bus.trip_id=stop_times_bus.trip_id GROUP by route_id) b WHERE a.route_id=b.route_id;";
    
#    $selectCreate = "CREATE TABLE serviceHours AS SELECT route_id, service_id, direction_id, MIN(arrival_time) min, MAX(arrival_time) max FROM stop_times_bus JOIN trips_bus ON trips_bus.trip_id=stop_times_bus.trip_id GROUP BY route_id,service_id,direction_id;";
    
    my $baseSelect;
    my $selectCreate;
    
    if ( ( -e 'direction.txt' )  ||  ( -e "busStopDirections.csv" ) )
    {
#        $baseSelect = "SELECT trips_bus.route_id as route_id, route_short_name, service_id, direction_id, Direction, MIN(arrival_time) as min, MAX(arrival_time) as max FROM stop_times_bus NATURAL JOIN trips_bus NATURAL JOIN routes_bus JOIN bus_stop_directions ON bus_stop_directions.Route=route_short_name  GROUP BY trips_bus.route_id, service_id, direction_id;";
    
#        $baseSelect = "SELECT t.route_id as route_id, route_short_name, service_id, direction_id, CASE WHEN Direction='Westbound' THEN 'West' WHEN Direction='Eastbound' THEN 'East' WHEN Direction='Northbound' THEN 'North' WHEN Direction='Southbound' THEN 'South' ELSE Direction END AS Direction, CASE WHEN dircode=\"NULL\" THEN NULL ELSE dircode END AS dircode, MIN(arrival_time) as min, MAX(arrival_time) as max FROM stop_times_bus s NATURAL JOIN trips_bus t NATURAL JOIN routes_bus r JOIN bus_stop_directions b ON b.Route=r.route_short_name AND b.dircode=t.direction_id GROUP BY t.route_id, t.service_id, t.direction_id, b.dircode;";

        # New, as of, 8/29.  Resolves idiotic issue where sometimes 24+ time is used for a few trips.  Because, you know!
        $baseSelect = "SELECT rid as route_id, route_short_name, service_id, direction_id, CASE WHEN Direction='Westbound' THEN 'West' WHEN Direction='Eastbound' THEN 'East' WHEN Direction='Northbound' THEN 'North' WHEN Direction='Southbound' THEN 'South' ELSE Direction END AS Direction, CASE WHEN dircode=\"NULL\" THEN NULL ELSE dircode END AS dircode, MIN(a) as min, MAX(a) as max FROM (SELECT route_short_name, t.route_id as rid, service_id, direction_id, CASE WHEN arrival_time > 2359 AND (route_short_name=\"BSO\" OR route_short_name=\"MFO\") THEN arrival_time-2400 ELSE arrival_time END as a FROM stop_times_bus NATURAL JOIN trips_bus t JOIN routes_bus r ON r.route_short_name=t.route_id) JOIN bus_stop_directions b ON b.Route=route_short_name GROUP BY route_id, service_id, direction_id;";

        # AND b.dircode=direction_id
        
#        SELECT route_short_name, t.route_id as rid, service_id, direction_id, CASE WHEN arrival_time > 2359 AND (route_short_name="BSO" OR route_short_name="MFO") THEN arrival_time-2400 ELSE arrival_time END as a FROM stop_times_bus NATURAL JOIN trips_bus t JOIN routes_bus r ON r.route_short_name=t.route_id
        
        $selectCreate = "CREATE TABLE serviceHours AS $baseSelect";
    }
    else
    {
        $baseSelect = "SELECT trips_bus.route_id as route_id, route_short_name, service_id, direction_id, NULL as Direction, NULL as dircode, MIN(arrival_time) min, MAX(arrival_time) max FROM stop_times_bus JOIN trips_bus ON trips_bus.trip_id=stop_times_bus.trip_id JOIN routes_bus ON routes_bus.route_id=trips_bus.route_id GROUP BY trips_bus.route_id,service_id,direction_id;";
        
        $selectCreate = "CREATE TABLE serviceHours AS $baseSelect";
    }
    
    
#    my $selectInsert = "INSERT INTO serviceHours SELECT a.route_id, a.min, b.max FROM (SELECT route_id, MIN(arrival_time) min FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id GROUP BY route_id) a, (SELECT route_id, MAX(arrival_time) max FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id GROUP by route_id) b WHERE a.route_id=b.route_id;";
    
#    my $selectInsert = "INSERT INTO serviceHours SELECT route_id, service_id, direction_id, MIN(arrival_time) min, MAX(arrival_time) max FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id GROUP BY route_id,service_id,direction_id;";
    
    my $selectInsert = "INSERT INTO serviceHours SELECT trips_rail.route_id as route_id, route_short_name, service_id, direction_id, NULL as Direction, NULL as dircode, MIN(arrival_time) min, MAX(arrival_time) max FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id JOIN routes_rail ON routes_rail.route_id=trips_rail.route_id GROUP BY trips_rail.route_id,service_id,direction_id;";

    
    print "pSH - selectCreate:\n\n$selectCreate\n\n";
    print "pSH - selectInsert:\n\n$selectInsert\n\n";
    
    
    my $message = "(this might take a few minutes)";
    print "pSH - Creating the table serviceHours with a CREATE TABLE $message";
    $dbh->do($selectCreate);
#    print "\b" x length($message);
    print "\n\tand INSERT INTO statement $message\n";
    $dbh->do($selectInsert);
    print "pSH - Finished creating new table\n\n";
    

    # Removing dependency on route_id
#    my $createStopLUT = "CREATE TABLE stopNameLookUpTable AS SELECT t.route_id as route_id, stop_id, direction_id FROM stop_times_bus NATURAL JOIN trips_bus t NATURAL JOIN routes_bus r WHERE r.route_short_name NOT IN ('MFL','BSS','NHSL') GROUP BY t.route_id, stop_id, direction_id;";
    
#    my $createStopLUT = "CREATE TABLE stopNameLookUpTable AS SELECT route_short_name, stop_id, direction_id FROM stop_times_bus NATURAL JOIN trips_bus t NATURAL JOIN routes_bus r WHERE r.route_short_name NOT IN ('MFL','BSS','NHSL') GROUP BY route_short_name, stop_id, direction_id;";

    my $createStopLUT = "CREATE TABLE stopNameLookUpTable AS SELECT route_short_name, stop_id, direction_id, stop_sequence FROM stop_times_bus NATURAL JOIN trips_bus t JOIN routes_bus r ON r.route_short_name=t.route_id WHERE r.route_short_name NOT IN ('MFL','BSS','BSL','NHSL') GROUP BY route_short_name, stop_id, direction_id;";

    
    # 5/15/13 -- Added direction_id to the GROUP BY portion say stops like OTC (382) will show both directions instead of just one
    $dbh->do($createStopLUT);
    
    my $InsertStopLUT = "INSERT INTO stopNameLookUptable SELECT route_id, stop_id, direction_id, stop_sequence FROM stop_times_rail NATURAL JOIN trips_rail t NATURAL JOIN routes_rail r GROUP BY route_id, stop_id, direction_id;";
    
    
#    $dbh->do("update serviceHours set Direction=replace(Direction,'Westbound','West')");
#    $dbh->do("update serviceHours set Direction=replace(Direction,'Eastbound','East')");
#    
#    $dbh->do("update serviceHours set Direction=replace(Direction,'Northbound','North')");
#    $dbh->do("update serviceHours set Direction=replace(Direction,'Southbound','South')");
    
    
    # stop_times_bus(trip_id INT, arrival_time TEXT, stop_id INT, stop_sequence INT)
    
    my $create;
    my @specialRoutes = ("MFL","NHSL","BSL");
    
    foreach my $rte (@specialRoutes)
    {
    
        $create = "SELECT s.trip_id AS trip_id, s.arrival_time AS arrival_time, s.stop_id AS stop_id, s.stop_sequence AS stop_sequence FROM stop_times_bus s NATURAL JOIN trips_bus t WHERE route_id=\"$rte\"";
        $dbh->do("CREATE TABLE stop_times_$rte AS $create;");
        
        
#        $create = "SELECT t.route_id AS route_id, service_id, trip_id, direction_id, block_id FROM trips_bus t NATURAL JOIN routes_bus r WHERE r.route_short_name=\"$rte\"";
        $create = "SELECT t.route_id AS route_id, service_id, trip_id, direction_id, block_id FROM trips_bus t WHERE route_id=\"$rte\"";
        $dbh->do("CREATE TABLE trips_$rte AS $create;");
        
        
        $dbh->do("CREATE INDEX trip_" . $rte . "IDX on stop_times_$rte (trip_id)");
        
    }
    
    
    $dbh->disconnect();
    
}



#
#  Only for Buses (maybe limit by route type)
#

my $optNoColor;
my $optRouteSelection;
my $optBusDirectory;


sub populateClosestStopMatch
{
    
    my $dbname = $_[0];
    
    if ( $dbname =~ /rail/ )
    {
        return;  # This table is only meant for Buses, BSO, and MFO but includes Trolleys, MFL, BSS and NHSL for now
    }

    # In order to build the first structure, we'll need to read from the following three files: trips.txt, stops.txt, stop_times.txt
    
    # From trips.txt     : trip_id, route_id and direction_id
    # From stop_times.txt: trip_id, stop_id
    # From stops.txt     : stop_id, stop_lat, stop_lon, stop_name
    
    my %routesHash;
    
    my %stopsHash;
    my %stopTimesHash;
    my %tripsHash;
    
    # TODO: $busDir should be supplied by the command line if google_bus is not the appropriate filename
    
    # Read in stops.txt first
    #    my $filename = fullPathFor("stops.txt");
    
    my $routeHashRef;
    my $stopsHashRef;
    my $stopTimesHashRef;
    my $tripsHashRef;
        
    
    # Only run if $optRouteSelection was specified on the command line
    if ( $optRouteSelection )
    {
        populateRoutesHash ( fullPathFor("routes.txt"),  $routeHashRef);
        findRouteFor($routeHashRef);
    }
    
    populateRoutesHash ( fullPathFor("routes.txt"),  $routeHashRef);
    populateStopsHash  ( fullPathFor("stops.txt"),      $stopsHashRef);
    populateTripsHash  ( fullPathFor("trips.txt"),      $tripsHashRef);
    
    
    if ( $stopsHashRef && $tripsHashRef )
    {
        $stopTimesHashRef = populateStopTimesHash( fullPathFor("stop_times.txt"), $stopsHashRef, $tripsHashRef);  # This will take a while and it needs to be last!  :(
    }
    
    
    #    foreach my $stopID ( keys %{$stopsHashRef} )
    #    {
    #        print "StopID: $stopID\n";
    #    }
    
    #    foreach my $tripID ( keys %{$tripsHashRef} )
    #    {
    #        print "TridID: $tripID\n";
    #    }
    
    my $gis = GIS::Distance->new();
    my $distance;  # Units: m
    my $smallestDist = 10000; # Units: m
    my $smallestStop;
    
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbname.\n\n";
    
    $dbh->do("BEGIN"); #The final stage of the SQLite database, BEGIN before the loop, COMMIT after it

#    $dbh->do("CREATE TABLE reverseStopSearch (route_id INT, stop_id INT, reverse_stop_id INT, distance REAL)");
    $dbh->do("CREATE TABLE reverseStopSearch (route_short_name TEXT, stop_id INT, reverse_stop_id INT, distance REAL)");
    my $questStr = "?,?,?,?";
    my $sth = $dbh->prepare("INSERT INTO reverseStopSearch VALUES ($questStr)");

#    print "route_id,stop_id,opposite_stop_id,distance_ft\n";
    
    my $routeShortName;
    foreach my $routeID ( keys %{$stopTimesHashRef} )
    {


        $routeShortName = $routeHashRef->{$routeID}{route_short_name};
        print "pClosest: route - $routeID ($routeShortName)\n";
        
#        if ( $routeShortName eq "LUCYGO" )
#        {
#            print "STOP\n";
#        }
        
        if ( $stopTimesHashRef->{$routeID}{0} && $stopTimesHashRef->{$routeID}{1} )
        {
            # Stops exist in both directions!  Otherwise it's a loop and this isn't needed.
            
            foreach my $dirID ( keys %{ $stopTimesHashRef->{$routeID} } )
            {
                
                my $otherDirID;
                $otherDirID = 1 if ($dirID == 0);
                $otherDirID = 0 if ($dirID == 1);
                
                foreach my $stops ( keys %{ $stopTimesHashRef->{$routeID}{$dirID} } )
                {
                    $smallestDist = 10000;
                    # Loop through all the $stops looking for the closest match in the other dir
                    
                    foreach my $otherStops ( keys %{ $stopTimesHashRef->{$routeID}{$otherDirID} } )
                    {
                        
                        #                        next if ( $stops == $otherStops );
                        # All the stops in the other direction.
                        
                        my $lat1 = $stopTimesHashRef->{$routeID}{$dirID}{$stops}{lat};
                        my $lon1 = $stopTimesHashRef->{$routeID}{$dirID}{$stops}{lon};
                        
                        my $lat2 = $stopTimesHashRef->{$routeID}{$otherDirID}{$otherStops}{lat};
                        my $lon2 = $stopTimesHashRef->{$routeID}{$otherDirID}{$otherStops}{lon};
                        
                        $distance = $gis->distance( $lat1, $lon1 => $lat2, $lon2 )->feet();  # Defaults to m
                        if ( $distance < $smallestDist )
                        {
                            
                            $smallestDist = $distance;
                            $smallestStop = $otherStops;
                            
                            #                            if ( $stops == 26818 )
                            #                            {
                            #    #                            print Dumper( $stopTimesHashRef->{$routeID}{$otherDirID}{$smallestStop} );
                            #                                my $output = sprintf("Closest stop to %5d in direction %1d is %5d with a distance of %6.4f feet\n", $stops, $dirID, $smallestStop, $smallestDist);
                            #                                print $output;
                            #                            }
                            
                        }
                        
                    } # foreach my $otherStops ( keys %{ $stopTimesHashRef->{$routeID}{$otherDirID} } )
                    
                    my $highLightStart = "";
                    my $highLightEnd   = "";
                    
                    if ( $smallestDist > 500 && !$optNoColor )
                    {
                        $highLightStart = "\e[1;31m";
                        $highLightEnd   = "\e[0m";
                    }
                    
                    #                    my $output = sprintf("Closest stop to %5d in direction %1d is %5d with a distance of %s%6.4f%s feet\n", $stops, $dirID, $smallestStop, $highLightStart, $smallestDist, $highLightEnd);
                    #                    print $output;
                    
                    $sth->execute( ($routeShortName,$stops,$smallestStop,$smallestDist) );
                    
#                    print "$routeID,$stops,$smallestStop,$smallestDist\n";
                    
                    
                    #                    if ( $smallestDist < 0.01 )
                    #                    {
                    #                        print Dumper( $stopTimesHashRef->{$routeID}{$dirID}{$stops} );
                    #                        print Dumper( $stopTimesHashRef->{$routeID}{$otherDirID}{$smallestStop} );
                    #                        print "\n";
                    #                    }
                    
                    #                    if ( $smallestDist > 500 )
                    #                    {
                    #                        print Dumper( $stopTimesHashRef->{$routeID}{$dirID}{$stops} );
                    #                        print Dumper( $stopTimesHashRef->{$routeID}{$otherDirID}{$smallestStop} );
                    #                        print "\n";
                    #                    }
                    
                    
                } # foreach my $stops ( keys %{ $stopTimesHashRef->{$routeID}{$dirID} } )
                
            } # foreach my $dirID ( keys %{ $stopTimesHashRef->{$routeID} } )
            
        } # if ( $stopTimesHashRef->{$routeID}{0} && $stopTimesHashRef->{$routeID}{1} )
        
        #        foreach my $dirID ( keys %{ $stopTimesHashRef->{$routeID} } )
        #        {
        #
        #            my $otherDirID;
        #            $otherDirID = 1 if ($dirID == 0);
        #            $otherDirID = 0 if ($dirID == 1);
        #
        #
        #
        #            my $num = scalar keys %{ $stopTimesHashRef->{$routeID}{$dirID} };
        #            print "Route: $routeID for dir: $dirID has $num stops\n";
        #
        #        }
        
    } # foreach my $routeID ( keys %{$stopTimesHashRef} )
    
    $dbh->do("COMMIT");
    $dbh->disconnect();

}


sub findRouteFor
{
    
    # This is redundant, but it still doesn't hurt to check
    if ( !$optRouteSelection )
    {
        # $optRouteSelection was never set, so there's nothing to do here
        return;
    }
    
    
    my %routesHash = %{ $_[0] };
    
    if ( $routesHash{$optRouteSelection} )
    {
        # If $optRouteSelection exists in $routesHash, everything is right in the world!  Return $optRouteSelection
        return $optRouteSelection;
    }
    else
    {
        foreach my $key (%routesHash)
        {
            if ( $routesHash{$key}->{route_short_name} =~ /$optRouteSelection/ )
            {
                $optRouteSelection = $key;
                return $key;
            }
        }
    }
    
}

sub populateRoutesHash
{
    
    my $filename = $_[0];
    my %thisHash;
    
    open ROUTES, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <ROUTES>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("route_id", "route_short_name", "route_long_name");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $routeID;
    my $routeShort;
    my $routeLong;
    
    my $hashRef;
    
    while (<ROUTES>)
    {
        my @line = split(/,/);
        
        $routeID     = $line[ $columns->{route_id}         ];
        $routeShort  = $line[ $columns->{route_short_name} ];
        $routeLong   = $line[ $columns->{route_long_name}  ];
        
        $hashRef = {route_id => $routeID, route_short_name => $routeShort, route_long_name => $routeLong};
        $thisHash{ $routeID } = $hashRef;
        
    }
    
    $_[1] = \%thisHash;
    close ROUTES;
    
}


sub populateTripsHash
{
    
    my $filename = $_[0];
    my %thisHash;
    
    open TRIPS, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <TRIPS>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("trip_id", "route_id", "direction_id");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $tripID;
    my $routeID;
    my $dirID;
    
    my $hashRef;
    
    while (<TRIPS>)
    {
        my @line = split(/,/);
        
        $routeID  = $line[ $columns->{route_id} ];  # routeID needs to contain a value for the optRouteSelection part to work
        
        if ( $optRouteSelection )
        {
            if ( $optRouteSelection !~ /$routeID/ )
            {
                next;  # If the route selected does not match $routeID, read the next line
            }
        }
        
        $tripID   = $line[ $columns->{trip_id}   ];
        $dirID    = $line[ $columns->{direction_id}  ];
        
        $hashRef = {trip_id => $tripID, route_id => $routeID, direction_id => $dirID};
        $thisHash{ $tripID } = $hashRef;
        
    }
    
    close TRIPS;
    
    $_[1] = \%thisHash;
    #    return \%stopsHash;
    
}


sub populateStopTimesHash
{
    
    my $filename  = $_[0];
    my %stopsHash = %{ $_[1] };
    my %tripsHash = %{ $_[2] };
    
    my %thisHash;
    
    open STOPTIMES, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <STOPTIMES>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("stop_id", "trip_ip");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $count = 0;
    while (<STOPTIMES>)
    {
        my @line = split(/,/);
        
        my $tripID   = $line[ $columns->{trip_id} ];
        if ( !$tripsHash{$tripID} )  # If tripsHash doesn't contain information for this tripID, skip to the next line
        {
            next;
        }
        
        
        my $stopID   = $line[ $columns->{stop_id}   ];
        
        my $stopName = $stopsHash{$stopID}->{stop_name};
        my $stopLat  = $stopsHash{$stopID}->{stop_lat};
        my $stopLon  = $stopsHash{$stopID}->{stop_lon};
        
        my $dirID    = $tripsHash{$tripID}->{direction_id};
        my $routeID  = $tripsHash{$tripID}->{route_id};
        
        #        print "RouteID: $routeID, DirID: $dirID\n";
        #        print $_;
        #
        
        if ( !$thisHash{$routeID}{$dirID}{$stopID} )
        {
            my $hashRef = { stop_id => $stopID, stop_name => $stopName, lat => $stopLat, lon => $stopLon, trip_id => $tripID };
            #            push(@{ $thisHash{$routeID}{$dirID}{$stopID} }, $hashRef);
            $thisHash{$routeID}{$dirID}{$stopID} = $hashRef;
        }
        
        #        if ( $thisHash{$routeID} )
        #        {
        # Already contains data, let's add to it!
        #        push(@{ $thisHash{$routeID}{$dirID}{$stopID} }, $hashRef);
        #        }
        #        else
        #        {
        #            # $thisHash{$routeID} is empty.  Let's fill it up!
        #            $thisHash{$routeID}{0} = ();
        #            $thisHash{$routeID}{1} = ();
        #
        #            push(@{ $thisHash{$routeID}{$dirID} }, $hashRef);
        #        }
        
        
        #        my $hashRef = {stop_id => $stopID, trip_id => $tripID};
        #        $thisHash{ $stopID } = $hashRef;
        
    }
    
    close STOPTIMES;
    
    #    $_[1] = \%thisHash;
    return \%thisHash;
    
}


sub populateStopsHash
{
    
    my $filename = $_[0];
    my %thisHash;
    
    open STOPS, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <STOPS>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("stop_id", "stop_name", "stop_lon", "stop_lat", "wheelchair_boarding");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    while (<STOPS>)
    {
        my @line = split(/,/);
        
        my $stopID   = $line[ $columns->{stop_id}   ];
        my $stopName = $line[ $columns->{stop_name} ];
        my $stopLon  = $line[ $columns->{stop_lon}  ];
        my $stopLat  = $line[ $columns->{stop_lat}  ];
        
        my $hashRef = {stop_name => $stopName, stop_lon => $stopLon, stop_lat => $stopLat};
        $thisHash{ $stopID } = $hashRef;
        
    }
    
    close STOPS;
    
    $_[1] = \%thisHash;
    #    return \%stopsHash;
    
}

sub fullPathFor
{
    
    my $filename;
    
    # First, check there was a directory based from the command line and, if so, if that directory contains the file we're looking for
    if ( $optBusDirectory )
    {
        $filename = "$optBusDirectory/$_[0]";
        if ( -e $filename )
        {
            # We found our filename.  Full stop.  Return the full path and filename.
            return $filename;
        }
    }
    
    
    # No directory was giving.  So, we'll try looking in google_bus and the current directory.
    $filename = "google_bus/$_[0]";
    
    # If stops.txt does not exist at $busDir, just try the current location
    unless (-e $filename)
    {
        $filename = $_[0];
        unless ( -e $filename )
        {
            # Still could not find it.
            print "\nERROR: Unable to locate $_[0]\n\n";
            exit;
        } # unless (-e $filename)
        
    } # unless (-e $filename)
    
    return $filename;
    
}


sub populateStopIDRouteLookup
{
 
    print "pSRL - Creating stopIDRouteLookup.  This may take a few moments.\n";
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    
#    Without Cardinal Directions
#    SELECT route_short_name, stop_id, route_type, direction_id, CASE Direction WHEN "Northbound" THEN "N" WHEN "Southbound" THEN "S" WHEN "Westbound" THEN "W" WHEN "Eastbound" THEN "E" ELSE Direction END As CardinalDir FROM stop_times_bus NATURAL JOIN trips_bus NATURAL JOIN routes_bus JOIN bus_stop_directions ON bus_stop_directions.dircode=direction_id WHERE CardinalDir NOT IN ("W","N","E","S");
    
#    With Cardinal Directions
#    SELECT route_short_name, stop_id, route_type, direction_id, CASE Direction WHEN "Northbound" THEN "N" WHEN "Southbound" THEN "S" WHEN "Westbound" THEN "W" WHEN "Eastbound" THEN "E" ELSE Direction END As CardinalDir FROM stop_times_bus NATURAL JOIN trips_bus NATURAL JOIN routes_bus JOIN bus_stop_directions ON Route=route_short_name WHERE dircode=trips_bus.direction_id GROUP BY routes_bus.route_id, stop_id ORDER BY stop_id
    
    
    
#    // Different totals:
#    sqlite> SELECT count(1) FROM (SELECT route_short_name, stop_id, route_type, direction_id, CASE Direction WHEN "Northbound" THEN "N" WHEN "Southbound" THEN "S" WHEN "Westbound" THEN "W" WHEN "Eastbound" THEN "E" ELSE Direction END As CardinalDir FROM stop_times_bus NATURAL JOIN trips_bus NATURAL JOIN routes_bus JOIN bus_stop_directions ON Route=route_short_name WHERE dircode=trips_bus.direction_id GROUP BY routes_bus.route_id, stop_id ORDER BY stop_id);
#    17762
#    sqlite> SELECT count(1) FROM (SELECT route_short_name, stop_id, route_type  FROM stop_times_bus NATURAL JOIN trips_bus NATURAL JOIN routes_bus GROUP BY route_id, stop_id ORDER BY stop_id);
#    18029
    
    
#    my $baseSelect = "SELECT route_short_name, stop_id, route_type  FROM stop_times_bus NATURAL JOIN trips_bus JOIN routes_bus r ON r.route_short_name=trips_bus.route_id GROUP BY route_id, stop_id ORDER BY stop_id";
    #my $baseSelect = "SELECT r.route_short_name, s.stop_id, r.route_type  FROM stop_times_bus s NATURAL JOIN trips_bus t JOIN routes_bus r ON r.route_short_name=t.route_id GROUP BY t.route_id, stop_id ORDER BY stop_id;";
    
    my $baseSelect = "SELECT t.route_id as route_short_name, stop_id, route_type, CASE Direction WHEN \"Eastbound\" THEN \"E\" WHEN \"Westbound\" THEN \"W\" WHEN \"Northbound\" THEN \"N\" WHEN \"Southbound\" THEN \"S\" ELSE Direction END as Direction, dircode FROM stop_times_bus s NATURAL JOIN trips_bus t JOIN routes_bus r ON r.route_short_name=t.route_id JOIN bus_stop_directions b ON t.route_id=b.Route WHERE t.direction_id=b.dircode GROUP BY route_short_name, stop_id, direction_id;";
    
    my $selectCreate = "CREATE TABLE stopIDRouteLookup AS $baseSelect;";
    $dbh->do($selectCreate);
    
    my $baseInsert = "SELECT route_id AS route_short_name, stop_id, route_type, \"X\" as Direction, \"2\" as dircode FROM stop_times_rail NATURAL JOIN trips_rail NATURAL JOIN routes_rail GROUP BY route_id, stop_id ORDER BY stop_id";
    my $selectInto = "INSERT INTO stopIDRouteLookup $baseInsert;";
    $dbh->do($selectInto);
    
    
    $dbh->disconnect();
    
    print "pSRL - Created table stopIDRouteLookup.  This table is used by Find Nearest Routes feature of the iPhone app.\n";
    
}


sub fixBSSNamingIssue
{
    
    print "pSRL - Change references of BSS to BSL.  This may take a few moments.\n";
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    
    my $baseRouteUpdate = "UPDATE routes_bus SET route_short_name=\"BSL\" WHERE route_short_name=\"BSS\"";
    my $baseTripsUpdate = "UPDATE trips_bus SET route_id=\"BSL\" WHERE route_id=\"BSS\"";
    
    $dbh->do($baseRouteUpdate);
    $dbh->do($baseTripsUpdate);
    
    $dbh->disconnect();
    
}


sub populateGlensideCombined
{

    print "pGC  - Create trips associated with the Glenside Combined\n";
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    

    my $baseInsert = "INSERT INTO trips_rail SELECT \"GC\" as route_id, service_id, trip_id, direction_id, block_id FROM trips_rail WHERE route_id IN (\"WAR\", \"WTR\", \"LAN\")";
    $dbh->do($baseInsert);
    
    $dbh->disconnect();

    
}



sub repairBSOMFOArrivalTime
{
    
    print "rBMAT  - Repairs issues where BSO and MFO arrival times are over 9000!  Er... I mean, 2400.\n";

    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    my $baseUpdate = "UPDATE stop_times_bus SET arrival_time = arrival_time-2400 WHERE arrival_time > 2400 AND trip_id IN (SELECT trip_id FROM trips_bus WHERE route_id IN (\"MFO\", \"BSO\") );";
    $dbh->do($baseUpdate);
    
    $dbh->disconnect();
    
    
}

sub combineMFLStops
{
    
    print "cMFLS - Combine 69th St Transportation Center MFL West/East into just 69th St Transportation Center\n\n";
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    
    my $east_stopID;
    my $west_stopID;
    
    my $sth = $dbh->prepare("SELECT stop_id FROM stops_bus WHERE stop_name = '69th St Transportation Center MFL West';");
    $sth->execute();
    
    my $row;
    $row = $sth->fetchrow_arrayref();
    $west_stopID = @$row[0];
    
    $sth = $dbh->prepare("SELECT stop_id FROM stops_bus WHERE stop_name = '69th St Transportation Center MFL East';");
    $sth->execute();
    
    $row = $sth->fetchrow_arrayref();
    $east_stopID = @$row[0];
    
    print "East: $east_stopID, West: $west_stopID\n";
    
    if ( !$east_stopID || !$west_stopID )
    {
        print "Could not find either East or West (or both)\n";
        
    }
    else
    {
        $sth->finish();
        
        my $updateQuery = "UPDATE stop_times_bus SET stop_id = $west_stopID WHERE stop_id = $east_stopID";
        $dbh->do($updateQuery);
        
        $updateQuery = "UPDATE stop_times_MFL SET stop_id = $west_stopID WHERE stop_id = $east_stopID";
        $dbh->do($updateQuery);
        
        
        my $deleteQuery = "DELETE FROM stops_bus WHERE stop_id = $east_stopID";
        $dbh->do($deleteQuery);
        
        
        $updateQuery = "UPDATE stops_bus SET stop_name = '69th St Transportation Center' WHERE stop_id = $west_stopID";
        $dbh->do($updateQuery);
    }
    
    $dbh->disconnect();
    
}


sub removeBadMFLStops
{
    
    print "rBMFLS  - Remove 69th St Transportation Center MFL East stop from Westbound trains\n";  # Passengers are unable to stay on the train as it loops around from the West to East stop.
    
    # E.g. (from prettifyStops.pl)
    # 3775411   18:43:00   18:43:00   27    7     1     12026   1      Millbourne Station (2446)
    # 3775411   18:44:00   18:44:00   28    7     1     12026   2      69th St Transportation Center MFL West (20845)
    # 3775411   18:47:00   18:47:00   29    7     1     12026   1      69th St Transportation Center MFL East (416)
    
    # The last stop (416) shouldn't be there as passengers cannot travel from 20845 -> 416.
    
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    my $baseDelete = "DELETE FROM stop_times_MFL WHERE trip_id IN (SELECT trip_id FROM trips_MFL NATURAL JOIN stop_times_MFL NATURAL JOIN stops_bus WHERE stop_id IN (SELECT stop_id FROM stops_bus WHERE stop_id IN (416, 20845) ) GROUP BY trip_id HAVING count(trip_id) > 1) AND stop_id=416;";
    $dbh->do($baseDelete);
    
    $dbh->disconnect();
    
    
}



sub removeEmployeeOnlyStops
{
    
    print "rEOS  - Remove all stop_times where the stop_name is Employees Only\n";
    
    # E.g.
    #   SELECT * FROM stops_bus WHERE stop_name LIKE '%employees only%';  returns
    #
    # 30855|Employee Platform - Employees Only|39.964486|-75.262625|
    # 30856|Employee Platform - Employees Only|39.964513|-75.263262|
    
    # These are not valid stops.  At the time these comments were written, only 30855 is found in stop_times_bus
    
    # --==  Connect to DB  ==--
    my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbFileName",
    "",
    "",
    { RaiseError => 1 },
    ) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";
    
    my @tableNames = ("stop_times_bus", "stop_times_NHSL", "stop_times_BSL", "stop_times_MFL");
    
    foreach my $tableName (@tableNames)
    {
        my $baseDelete = "DELETE FROM $tableName WHERE stop_id IN (SELECT stop_id FROM stops_bus WHERE stop_name LIKE '%employees only%');";
        print "$baseDelete \n";
        $dbh->do($baseDelete);
    }
    
    $dbh->disconnect();
    
    
}


sub createMD5File
{
    
#    system("md5 SEPTA.sqlite > SEPTA.md5");
    
    my $md5hash = `md5 SEPTA.sqlite`;
    
    $md5hash =~ /([a-zA-Z\d]+$)/;
    my $keyValue = '[{"md5": "' . $1 . '"}]' . "\n";
    
    print $keyValue;
    
    open(my $md5file, ">", "SEPTA.md5") or die "Cannont open > SEPTA.md5: $!";
    print $md5file $keyValue;
    close($md5file);
    
#    system("echo $keyValue > SEPTA.md5");
    
#    print "md5: $1, length: " . length($1) . "\n";
    
    
}
