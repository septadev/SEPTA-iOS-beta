#!/usr/bin/perl

# TODO
#

# KNOWN ISSUES
#   - 110B and 10B will both be truncated the same way, causing collisions.
#   - Does not check if the new tid already exists, or if the current tid has not been previously assigned


use strict;

use DBI;
use Digest::MD5 qw(md5_hex);
use List::Util 'first';


# --==  CONSTANTS  ==--
my $dbFileName = "SEPTA.sqlite";
# --==  CONSTANTS  ==--


# --==  Connect to DB  ==--
my $dbh = DBI->connect(
"dbi:SQLite:dbname=$dbFileName",
"",
"",
{ RaiseError => 1 },
) or die "DBIerr: " . $DBI::err . "\nDBIerrstr: " . $DBI::errstr . "\nGTFS - DBName: $dbFileName.\n\n";



#my $sqlQuery = "SELECT * FROM routes_rail;";
my $sqlQuery = "SELECT tbl_name FROM sqlite_master WHERE type='table';";

my $sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
$sth->execute() or die "Can't execute statement: $DBI::errstr\n";

my $row;
my $results = $sth->fetchall_arrayref();

my @tableNames;

print "\n";
my $string = "";
foreach $row (@$results)
{
#    $string .= sprintf("%s,%s,%s,%s", @$row[0], @$row[1], @$row[2], @$row[3]);
    push(@tableNames, @$row[0]);
}


my @rowCount;

foreach my $table (@tableNames)
{
    
    $sqlQuery = "SELECT count(1) FROM $table;";
    $sth = $dbh->prepare($sqlQuery);
    $sth->execute() or die "Can't execute statement: $DBI::errstr\n";
    
    my $count = $sth->fetch();
#    printf("%-20s: %-8s rows\n", $table, @$count);

    my $unsortedRef = {'table' => $table, 'count' => @$count};
    push(@rowCount, $unsortedRef);
    
    
#    $results = $sth->fetchall_arrayref();
#    print @$results . "\n";
    
    $sqlQuery = "SELECT * FROM $table;";
    $sth = $dbh->prepare($sqlQuery);
    $sth->execute() or die "Can't execute statement: $DBI::errstr\n";

    $results = $sth->fetchall_arrayref();
    
    $string = "";
    foreach $row (@$results)
    {
        $string .= join(',', @$row);
    }
    
    printf("%-20s: %s\n", $table, md5_hex($string) );
    
}

my @sorted = sort { $b->{count} <=> $a->{count} } @rowCount;

foreach $row (@sorted)
{
    printf("%-20s: %-8s rows\n", $row->{table}, $row->{count} );
}


exit(1);


# Get all routes
# SELECT route_id FROM routes_bus
# SELECT route_id FROM routes_rail

# SELECT * FROM trips_bus WHERE route_id=$routeID


#$sqlQuery = "SELECT route_short_name FROM routes_bus";
#my $sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
#$sth->execute() or die "Can't execute statement: $DBI::errstr\n";
#
#$results = $sth->fetchall_arrayref();
#
#my @routeNames;
#
#print "\n";
#foreach $row (@$results)
#{
#    push(@routeNames, @$row[0]);
#}
#
#
#foreach my $routeID (@routeNames)
#{
#    
#    my $query = "SELECT * FROM trips_bus WHERE trip_id IN (SELECT trip_id FROM (SELECT trip_id, MIN(arrival_time) mint FROM stop_times_bus WHERE trip_id IN (SELECT trip_id FROM trips_Bus WHERE route_id='$routeID') GROUP BY trip_id) ORDER BY mint);";
#    
#    $sth = $dbh->prepare($query) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
#    $sth->execute() or die "Can't execute statement: $DBI::errstr\n";
#    
#    $results = $sth->fetchall_arrayref();
#    
#    foreach $row (@$results)
#    {
#        print $row . "\n";
#    }
#    
#}


# sqlite> CREATE TABLE orderedTrips AS SELECT substr('000'||route_id,-3,3) || substr('0000'||mint,-4,4) as tid, trip_id, route_id, service_id FROM (SELECT arrival_time, route_id, service_id, trip_id, direction_id, block_id, MIN(arrival_time) mint FROM stop_times_bus NATURAL JOIN trips_bus GROUP BY trip_id ORDER BY route_id, mint, service_id) ORDER BY service_id, tid;

# CREATE table named orderedTrips with _bus
# Repeat for trips_BSL, trips_MFL, trips_NHSL  (trips_rail is fine; no need to change ids)
# REPLACE trip_id with tid IN trips_bus and stop_times_bus


# Does orderedTrips table already exist?
my $match = first { /orderedTrips/ } @tableNames;

if ( $match )
{
    $dbh->do("DROP TABLE orderedTrips");
}


#my @dbtype = ("bus","MFL","BSL","NHSL");
my @dbtype = ("bus");
my $type = shift(@dbtype);

my $createTable = "CREATE TABLE orderedTrips (tid INT, trip_id INT, route_id TEXT, service_id INT, direction_id INT, stop_id INT, md5 TEXT)";
$dbh->do($createTable);

#my $createQuery = "CREATE TABLE orderedTrips AS SELECT substr('000'||route_id,-3,3)  || substr('0000'||mint,-4,4) as tid, trip_id, route_id, service_id, direction_id, stop_id FROM (SELECT arrival_time, route_id, service_id, trip_id, direction_id, block_id, stop_id, MIN(arrival_time) mint FROM stop_times_TBLNAME NATURAL JOIN trips_TBLNAME GROUP BY trip_id ORDER BY route_id, mint, service_id) ORDER BY service_id, tid;";

my $createQuery = "INSERT INTO orderedTrips (tid, trip_id, route_id, service_id, direction_id, stop_id) SELECT substr('000'||route_id,-3,3) || substr('0000'||mint,-4,4) as tid, trip_id, route_id, service_id, direction_id, stop_id FROM (SELECT arrival_time, route_id, service_id, trip_id, direction_id, block_id, stop_id, MIN(arrival_time) mint FROM stop_times_TBLNAME NATURAL JOIN trips_TBLNAME GROUP BY trip_id ORDER BY route_id, mint, service_id) ORDER BY service_id, tid;";

$createQuery =~ s/TBLNAME/$type/g;

print "\nCreating orderedTrips.  This might take a few moments...\n";
$dbh->do($createQuery) or die "Couldn't do it!";
print "orderedTrips created.\n";



my $masterQuery = "INSERT INTO orderedTrips (tid, trip_id, route_id, service_id) SELECT substr('000'||route_id,-3,3) || direction_id || substr('0000'||mint,-4,4) as tid, trip_id, route_id, service_id, direction_id, stop_id FROM (SELECT arrival_time, route_id, service_id, trip_id, direction_id, block_id, stop_id, MIN(arrival_time) mint FROM stop_times_TBLNAME NATURAL JOIN trips_TBLNAME GROUP BY trip_id ORDER BY route_id, mint, service_id) ORDER BY service_id, tid;";

my $insertQuery;


foreach $type (@dbtype)
{
    $insertQuery = $masterQuery;
    $insertQuery =~ s/TBLNAME/$type/g;
    
    $dbh->do($insertQuery);
    
}


# Find duplicate tids

# SELECT substr('   '||route_id,-3,3), t.trip_id, substr('     '||stop_id,-5,5), substr('  '||stop_sequence,-2,2), substr('    '||arrival_time,-4,4), substr('    '||MIN(arrival_time),-4,4), tid FROM trips_bus t NATURAL JOIN stop_times_bus st NATURAL JOIN orderedTrips WHERE t.trip_id IN (SELECT trip_id FROM orderedTrips WHERE tid IN (SELECT tid FROM orderedTrips GROUP BY tid, service_id HAVING count(tid) >= 4)) GROUP BY trip_id ORDER BY tid, route_id;

$sqlQuery = "SELECT tid, trip_id FROM trips_bus t NATURAL JOIN stop_times_bus st NATURAL JOIN orderedTrips WHERE t.trip_id IN (SELECT trip_id FROM orderedTrips WHERE tid IN (SELECT tid FROM orderedTrips GROUP BY tid HAVING count(tid) >= 2)) GROUP BY trip_id ORDER BY tid, route_id, service_id, stop_id;";

$sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
$sth->execute() or die "Can't execute statement: $DBI::errstr\n";

print "Query: $sqlQuery\n";

$results = $sth->fetchall_arrayref();

my %tidsHash;

print "\n";
my $string = "";
my $key;
my $count = ord('A');
my $matchesFound = 0;


$sth = $dbh->prepare("UPDATE orderedTrips SET tid =? WHERE trip_id=?");

foreach $row (@$results)
{

    $key = @$row[0];
    if ( $tidsHash{ $key } )
    {
        $key = $key . chr($count++);
#        print "Match found - new key: $key\n";
#        $count++;
        $matchesFound++;
#        my $updateQuery = "UPDATE orderedTrips SET tid = \"$key\" WHERE trip_id=@$row[1]";
#        $dbh->do($updateQuery);
#        print "execute( $key, @$row[1])\n";
        $sth->execute($key, @$row[1]);
        $sth->finish();
#        print "$updateQuery\n";
        
    }
    else
    {
#        print "First time found - $key\n";
        $tidsHash{ $key } = 1;
        $count = ord('A');  # reset count back to its initial value
        $matchesFound++;
    }
    
}


#print "Found $matchesFound matches\n";


print "Number of collisions before: " . scalar @$results . "\n";

$sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
$sth->execute() or die "Can't execute statement: $DBI::errstr\n";

$results = $sth->fetchall_arrayref();
$sth->finish();

print "Number of collisions after : " . scalar @$results . "\n";

#  This is no an exhaustive check.  There might be duplicates that still exist.
if ( scalar @$results > 0 )
{
    print "There should be no collisions at this point.  Exiting script.\n";
    exit(1);
}


# Note: Instead of adding an 1, 2, 3, etc. at the end of tid for each duplicate, A, B, C would ensure no duplicates

# Update trips_bus, trips_MFL, trips_BSL and trips_NHSL with the new trip_id

$masterQuery = "SELECT tid, trip_id FROM orderedTrips";
$sqlQuery = "SELECT tid, trip_id FROM orderedTrips";

@dbtype = ("bus","MFL","BSL","NHSL");


my $tid;
my $trip_id;
#my $masterStr = "UPDATE trips_TBLNAME SET trip_id=? WHERE trip_id=?";

my @masterArr = ("UPDATE trips_TBLNAME SET trip_id=? WHERE trip_id=?","UPDATE stop_times_TBLNAME SET trip_id=? WHERE trip_id=?");
my $masterStr;
my $updateStr;

my @tableArr = ("trips","stop_times");
my $LCV = 0;

foreach $masterStr (@masterArr)
{
    
    foreach $type (@dbtype)
    {

        $sqlQuery = $masterQuery;
        $sqlQuery .= " WHERE route_id=\"MFL\"" if ($type =~ /MFL/);
        $sqlQuery .= " WHERE route_id=\"MFL\"" if ($type =~ /BSL/);
        $sqlQuery .= " WHERE route_id=\"MFL\"" if ($type =~ /NHSL/);

        
        $sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
        $sth->execute() or die "Can't execute statement: $DBI::errstr\n";
        
        $results = $sth->fetchall_arrayref();
        $sth->finish();
        
        $updateStr = $masterStr;
        $updateStr =~ s/TBLNAME/$type/g;
        print "$updateStr\n";
        
        my $updateth = $dbh->prepare($updateStr);


        foreach $row (@$results)
        {
            $tid = @$row[0];
            $trip_id = @$row[1];
#            print "$tableArr[$LCV]_$type: execute( $tid, $trip_id ) \n";
            $updateth->execute( $tid, $trip_id );
            $updateth->finish();

        }  # foreach $row (@$results)
        
    } # foreach $type (@dbtype)

    $LCV++;
    
} # foreach $masterStr (@masterArr)



#$createQuery =~ s/DBTYPE/MFL/;
#$createQuery =~ s/DBTYPE/BSL/;
#$createQuery =~ s/DBTYPE/NSHL/;


# The new tripID:  XXX S TTTT
#   Where XXX is the three digit abbrievation for the route.  I.e. 1, 23, LGO, XH
#   S is the service id
#   TTTT is the MIN(arrival_time) for that trip

# Why?
#   * Unique tripID between GTFS updates
#   * Compare tripID from new GTFS to the old GTFS.  For every match, compare the MD5
#   * If the new tripID doesn't exist in the old one, add it.
#   * If the old tripID doesn't exist in the new one, delete it.
#   * Generate MD5 hash of update trips table (for that route), compare it with new GTFS <-- SHOULD MATCH

# trips table: CREATE TABLE trips_bus(route_id INT, service_id INT, trip_id INT PRIMARY KEY, direction_id INT, block_id TEXT);
# stop_times : CREATE TABLE stop_times_bus(trip_id INT, arrival_time INT, stop_id INT, stop_sequence INT);

# { [ { trip:"1620620", md5:"A13...BC" }, { trip:"1620640", md5:"52A...4F" }, { ... } ] }
# { [ { route_id:""   , service_id:"", trip_id:"", direction_id:"", block_id:"", md5:"A13...BC" }, { ... } ] }

# The MD5 hash is that all the rows from the stop_times table associated with the trip_id

# trips_bus is 35,000 records
# { columns: ["route_id", "service_id", "trip_id", "direction_id", "block_id", "md5"], "values": [[ ... ], [ ... ] ] }

# orderedTrips needs be created in order to speed up MD5 hash creation
# Once the entire DB has been updated, the orderedTrips table needs to update itself

# If the old tripID doesn't exist in the new one, delete everything associated with it from the trips table ( one record ) and the stop_times table (multiple records)

# The MD5 h

# SELECT trip_id, arrival_time, stop_id, stop_sequence FROM orderedTrips NATURAL JOIN stop_times_bus WHERE route_id="23" ORDER BY orderedTrips.rowid;

# CREATE TABLE orderedTrips AS SELECT arrival_time, route_id, service_id, trip_id, direction_id, block_id, MIN(arrival_time) mint FROM stop_times_bus NATURAL JOIN trips_bus GROUP BY trip_id ORDER BY route_id, mint, service_id;

# SELECT ot.route_id, service_id, ot.trip_id, direction_id, block_id FROM orderedTrips ot NATURAL JOIN trips_bus t WHERE ot.route_id="23" ORDER BY ot.rowid;


#print "$string\n";
#print md5_hex($string) ."\n";


# Now, let's build the MD5 hash table
# md5_hashs
# table_name | md5 | id

# If route_id is NULL, it includes the entire range
# stop_bus | ... | ALL
# trip_bus | ... | ALL
# trip_bus | ... | 1
# trip_bus | ... | 2
# trip_bus | ... | 232612A
# stop_times_bus | ... | ALL
# etc.


makeMD5();


warn $DBI::errstr if $DBI::err;

$dbh->disconnect();



$dbh->disconnect();

print "\n";



sub makeMD5
{
    
    print "\n";
    
    # How the download mechanism will work, there's an overall MD5 of the table and then an MD5 of each route
    my $sqlQuery = "SELECT tid, route_id FROM orderedTrips ORDER BY tid+0, route_id, service_id;";
    
    my $sth = $dbh->prepare($sqlQuery) or die "Can't prepare statement: \n$sqlQuery\n$DBI::errstr\n";
    $sth->execute() or die "Can't execute statement: $DBI::errstr\n";
    
    my $results = $sth->fetchall_arrayref();
    $sth->finish();
    
    my $currentRoute = "";
    my $tid;
    my $route_id;
    my @tidsArr;
    my $newRoute = 0;
    my $trip_id;
    
    foreach my $row (@$results)
    {
        
        $tid = @$row[0];
        $route_id = @$row[1];
#        $trip_id = @$row[2];
        
#        print $route_id . "\n";
        
        if ( !$currentRoute )
        {
            $currentRoute = $route_id;
        }
        
        if ( $currentRoute ne $route_id )
        {
            $newRoute = 1;
        }
        else
        {
            
        }
        
        if ( $newRoute )
        {
            
            # Get all stop_times values for this one
            $sqlQuery = "SELECT trip_id, arrival_time, stop_id, stop_sequence FROM stop_times_bus WHERE trip_id=?";
            $sqlQuery = "SELECT st.trip_id, st.arrival_time, st.stop_id, st.stop_sequence, ot.trip_id FROM stop_times_bus st JOIN orderedTrips ot ON st.trip_id=ot.tid WHERE st.trip_id=?";
            $sth = $dbh->prepare($sqlQuery);
            
            my $string = "";
            my $singleStr = "";
            my $md5String;
            
            foreach my $thistid (@tidsArr)
            {
                $sth->execute($thistid);
                # CREATE TABLE stop_times_bus(trip_id INT, arrival_time INT, stop_id INT, stop_sequence INT);
                my $tripResults = $sth->fetchall_arrayref();
                
                $singleStr = "";
                foreach my $eachRow (@$tripResults)
                {
#                    print $eachRow . "\n";
                    $trip_id = pop(@$eachRow);
                    for (my $LCV=0; $LCV < scalar @$eachRow; $LCV++)
                    {
                        $singleStr .= @$eachRow[$LCV] . ",";
                    }

                }  # foreach my $eachRow (@$tripResults)

                
                $string .= $singleStr;
                
                chop($singleStr);
                printf("Rte: %-10s (%10s) -- %s\n", $thistid, $trip_id, md5_hex($singleStr) );
                
            } # foreach my $thistid (@tidsArr)
            
            chop($string);
            $md5String = md5_hex($string);
            
            printf("Rte: %-10s -- %s\n", $currentRoute, $md5String);  # MD5 of all the stop_times for a Rte
            
            $newRoute = 0;
            @tidsArr = ();
            $currentRoute = $route_id;

        }
        
        push(@tidsArr, $tid);
        
    }
    
}

