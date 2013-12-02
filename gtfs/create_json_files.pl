#!/usr/bin/perl

# This was written months ago and needs to be updated.  It uses the GTFS instead of the sqlite3 database generated from it.
#   Thus a few custom tables will be missing from the output.

use strict;

use DBI;
use POSIX;

use Data::Dumper;
use feature 'say';

use JSON;

# GLOBAL VARIABLES
# ----------------
my $busDir  = "google_bus";  #Dependent on @dbfile name containing 'bus'
my $railDir = "google_rail"; #Dependent on @dbfile name containing 'rail'

my @tables = ("routes", "trips", "stops", "stop_times");  #createQuery needs to match up with this order and size
my @dbfile = ("bus", "rail");   # The DBs to create
#my @dbfile = ("SEPTArail.sqlite");   # The DBs to create

sub generateJSONFiles
{
    
    my %allroutes = ();
    my %alltrips  = ();
    my %allstops  = ();
    
    my %allfather = ();
    
    my $discardFirstLine;
    my $headersFromFile;
    
    my $type = $_[0];
    my $json = JSON->new->allow_nonref;
    
    
    if ( $type !~ /bus|rail/ )
    {
        print "Unable to determine which time to use\n";
        return;
    }
    
    my $dir;
    if ( $type =~ /bus/ )
    {
        $dir = $busDir;
    }
    else
    {
        $dir = $railDir;
    }
    
    
    # Check if JSON directory exists
    if ( -d "JSON/" )
    {
        # directory exists, nothing to do
    }
    else
    {
        mkdir "JSON";
    }
    
    my @routeNames  = ();
    my %columnNames = ();
    my $outputFile  = "JSON/" . $type . "_routes.json";
    open OUTPUT, ">$outputFile" or die "Could not create $outputFile.  Err: $!\n";
    
    my $filename = $dir . "/routes.txt";
    open FILE, $filename or die "Could not open $filename err: $!\n";
    $headersFromFile = <FILE>;
    s/,[ ]+/,/g;
    
    my @headersWeCareAbout  = ("route_id","route_short_name", "route_type");
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my $columns = {};
    
    %columnNames = ( columns => ["route_id","route_short_name","route_type"] );
    @{ $columnNames{values} } = ();
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    while (<FILE>)
    {
                
        my @routeArr = split(/,/);
        my $routeHash = {};
        
        foreach my $index (keys %$columns)  # For Bus GTFS data, columns might look like this... columns{stop_name} = 1, columns{stop_lat} = 2, etc.
        {                                   # For Rails, however, the columns might look like this... columns{stop_name} = 2, columns{stop_lat} = 3, etc.
            $routeHash->{$index} = $routeArr[$columns->{$index}];
        }
        
        my @routeData = ();
        push(@routeData, $routeArr[$columns->{route_id}]);
        push(@routeData, $routeArr[$columns->{route_short_name}]);
        push(@routeData, $routeArr[$columns->{route_type}]);
        
        push(@{ $columnNames{values} }, \@routeData);
        
        $allroutes{ $routeArr[$columns->{route_id}] } = $routeHash;
        
#        push(@routeNames, $routeArr[$columns->{route_short_name}]);
#        my $json_string = $json->encode( $routeHash );
#        print OUTPUT "$json_string\n";
        
    }
    
    my $json_string = $json->encode( \%columnNames );
    print OUTPUT "$json_string\n";
    
    close FILE;
    close OUTPUT;

    #
    ##  trips
    #
    # trips.txt      : route_id(0), service_id(1), trip_id(2), trip_headsign(3), block_id(4), direction_id(5), shape_id(6)
    $filename = $dir . "/trips.txt";
    open FILE, $filename or die "Could not open $filename err: $!\n";
    $headersFromFile = <FILE>;
    s/,[ ]/,/g;
    
    
    @headersWeCareAbout  = ("route_id","trip_headsign","direction_id","trip_id","service_id");
    @headerArrayFromFile = split(/,/, $headersFromFile);
    $columns = {};
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    while (<FILE>)
    {
        s/,[ ]+/,/g;
        my @trip = split(/,/);
        my $tripHash = {};
        
        foreach my $index (keys %$columns) # For Bus GTFS data, columns might look like this... columns{route_id} = 0, columns{trip_headsign} = 3
        {
            $tripHash->{$index} = $trip[$columns->{$index}];
        }
        #        my $tripHash = { 'route_id' => $trip[0], 'trip_headsign' => $trip[3], 'direction_id' => $trip[5] };
        
        $alltrips{ $trip[$columns->{trip_id}] } = $tripHash;
    }
    close FILE;
    
    
    
    #
    ##  stops
    #
    # stops.txt      : stop_id(0), stop_name(1), stop_lat(2), stop_lon(3), location_type(4), parent_station(5), zone_id(6)
    $filename = $dir . "/stops.txt";
    open FILE, $filename or die "Could not open $filename err: $!\n";
    $headersFromFile = <FILE>;
    s/,[ ]/,/g;
    
    
    @headersWeCareAbout  = ("stop_name", "stop_lat", "stop_lon", "stop_id");
    @headerArrayFromFile = split(/,/, $headersFromFile);
    $columns = {};
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    while (<FILE>)
    {
        s/,[ ]+/,/g;
#        $_ = filterOutTheCrapAtTheEndOfTheLine($_);
#        $_ = reverseStreetAddressAndStreet($_);
        my @stops = split(/,/);
        my $stopsHash = {};
        
        foreach my $index (keys %$columns)  # For Bus GTFS data, columns might look like this... columns{stop_name} = 1, columns{stop_lat} = 2, etc.
        {
            $stopsHash->{$index} = $stops[$columns->{$index}];
        }
        #        my $stopsHash = { 'stop_name' => $stops[1], 'stop_lat' => $stops[2], 'stop_lon' => $stops[3] };
        $allstops{ $stops[$columns->{stop_id}] } = $stopsHash;
    }
    close FILE;
    
    
    
    ##  stop_times
    #
    # stop_times.txt : trip_id(0), arrival_time(1), departure_time(2), stop_id(3), stop_sequence(4)
    $filename = $dir . "/stop_times.txt";
    open FILE, $filename or die "Coul not open $filename err: $!\n";
    my $headersFromFile = <FILE>;
    s/,[ ]/,/g;
    
    @headersWeCareAbout  = ("trip_id", "arrival_time", "departure_time", "stop_id", "stop_sequence");
    @headerArrayFromFile = split(/,/, $headersFromFile);
    $columns = {};
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    my %hash = ();
    my $hashRef = {};
    
    my $fileLength = `wc -l < $filename`;
    my $count = 0;
    my $output = "";
    my @sqlArray;
    while (<FILE>)
    {
        
        # This just prints out what percentage of the file has been read in
        if ( ( $. % 10000 ) == 0 )
        {
            my $percentage = (1- abs($.-$fileLength)/$fileLength) * 100;
            $percentage =~ /([0-9]{1,2})\.([0-9]{1,2})/;
            my $percent = "$1.$2";
            
            if ( $output ne "" )
            {
                print "\b" x length($output);
            }
            
            $output = "GJF: Read $percent% of the $filename";
            print $output;
            
        } # if ( ( $. % 10000 ) == 0 )
        
        
        my @stopTimesArray = split(/,/);  # Important fileds: trip_id, arrival_time, departure_time, stop_id, stop_sequence
        @sqlArray = ();  # Clear the array
        
        # Use trip_id to get trip_headsign and route_id
        # Use route_id to get route_short_name
        
        # (stop_name, stop_id, route_id, trip_id,   direction_id, route_short_name, trip_headsign, arrival_time,   departure_time, stop_sequence)
        
        
        # TRIPS.TXT
        # ---------
        my $trip_id        = $stopTimesArray[$columns->{trip_id}];
        my $service_id     = $alltrips{ $trip_id }->{'service_id'};
        my $direction_id   = $alltrips{ $trip_id }->{'direction_id'};
        my $trip_headsign  = $alltrips{ $trip_id }->{'trip_headsign'};
        
        
        # ROUTES.TXT
        # ----------
        my $route_id       = $alltrips{ $trip_id }->{'route_id'};
        my $routeShortName = $allroutes{ $route_id }->{'route_short_name'};
        
        
        # STOP_TIMES.TXT
        # --------------
        my $arrivalTime    = $stopTimesArray[$columns->{arrival_time}];
        my $departureTime  = $stopTimesArray[$columns->{departure_time}];
        my $stopSequence   = $stopTimesArray[$columns->{stop_sequence}];
        my $stop_id        = $stopTimesArray[$columns->{stop_id}];
        
        # STOPS.TXT
        # ---------
        my $stop_name      = $allstops{ $stop_id }->{'stop_name'};
        
        
        $stopSequence =~ s/[\n\r]+//g;
        
#        %hash = ();
#        $hashRef = {};
#        $hash{stop_id} = $stop_id;
#        $hash{trip_id} = $trip_id;
#        $hash{arrival_time} = $arrivalTime;
#        $hash{departure_time} = $departureTime;
#        
#        $hash{stop_sequence} = $stopSequence;
#        $hash{direction_id}  = $direction_id;
#        $hash{service_id}    = $service_id;
        
        
        # Let's do a little trimming.  You know, for science!
        $arrivalTime   =~ s/\:00$//;
        $departureTime =~ s/\:00$//;
        
        push( @sqlArray, $stop_id);
        push( @sqlArray, $trip_id);
        push( @sqlArray, $arrivalTime);
        push( @sqlArray, $departureTime);
        
        push( @sqlArray, $stopSequence);
        push( @sqlArray, $direction_id);
        push( @sqlArray, $service_id);
        
        push( @{ $allfather{ $route_id } }, [ @sqlArray ] );
#        push( @{ $allfather{ $route_id } }, [ %hash ] );
        $count++;
 
    }  # while (<FILE>)
 
    print "\n";
    my $total = 0;
    my $output = "";
    
    my %columnHashRef = ();
    %columnHashRef = ( columns => ["stop_id", "trip_id", "arrival_time", "departure_time", "stop_sequence", "direction_id", "service_id"]);
    
    foreach my $routeID (keys %allfather )
    {
        
        my $tablename;
        if ( $type =~ /bus/ )
        {
            $tablename = "route_" . $allroutes{$routeID}->{'route_short_name'};
        }
        else
        {
            $tablename = "route_" . $allroutes{$routeID}->{'route_id'};
        }
        
        print "\b" x length($output);
        $output = "GJF: Populating $tablename...";
        print $output;

        my @routeArr = @{ $allfather{ $routeID } };

        
        @{ $columnHashRef{values} } = ();
        my $output = "JSON/" . $type . $tablename . ".json";
        open OUTPUT, ">$output" or die "Could not open $output.  Err: $!\n";
        
#        print OUTPUT $json->encode( \%columnHashRef ) . "\n";
#        print OUTPUT "{\"values\": {\n";
        foreach my $record (@routeArr)
        {
#            print OUTPUT $json->encode($record) . ",\n";
            push( @{ $columnHashRef{values} }, $record)
        }
#        print OUTPUT "}";
        
        print OUTPUT $json->encode( \%columnHashRef ) . "\n";
        close OUTPUT;
        
        #        print "Route $routeID has $#arr elements\n";
        $total += ($#routeArr+1);
        
    } # foreach my $routeID (keys %allfather )
    
    print "\n";

    
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


# MAIN
# ----

print "\n";

#my $user = "Johnny";


# Example usage:
#
#my $json_hash = {};  # Create a hash reference
#$json_hash{whatever} = 1;
#$json_hash{greg} = 0;
#$json_string = $json->encode( \%json_hash );
# Output: {"whatever":1,"greg":0}



foreach my $type (@dbfile)
{
    
    print "MAIN: Building JSON files for $type\n";
    
    # Create the folling JSON files:
    #  bus_routes.txt
    #  bus_route_1.txt
    #  bus_route_XXX.txt
    #  bus_stops.txt
    #  bus_unique_stops.txt
    
    # Repeeat for rail
    generateJSONFiles($type);
    
 
}