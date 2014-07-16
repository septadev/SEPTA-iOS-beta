#!/usr/bin/perl

use strict;
#use Term::ReadKey;

use Getopt::Long;

use Data::Dumper;
use feature 'say';

my $stopTimesFile = "stop_times.txt";
my $stopsFile     = "stops.txt";
my $tripsFile     = "trips.txt";

#Build hash from stops.txt
my %stop_ids;
my %trip_ids;
my @details;

# TODO: Auto detect if trips or rails.
# TODO: Determine direction id

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
    
}  # sub returnColumnsWeCareAbout

sub usage
{
    print "\n\nUsage:\n";
    print "  perl prettifyStopTimes.pl <trip_id:req> <bus|rail:opt>\n\n";
    print "Example:\n";
    print "  perl prettifyStopTimes.pl 3307161 bus\n";
    print "  perl prettifyStopTimes.pl 3307161          <--- (defaults to bus)\n";
    print "  perl prettifyStopTimes.pl WAR_403_V6 rail\n\n";
    exit 1;
}

sub trim
{
    $_[0] =~ s/^\s*//;
    $_[0] =~ s/\s*$//;
    return $_[0];
}

#print "ARGV count: $#ARGV\n\n";

# prettifyStopTimes redefined!
# prettifyStopTimes -r WAR_403_V6
# prettifyStopTimes -b 3307161
# prettifyStopTimes -r WAR_403_V6 -f   # displays only the first sequence;  -f1 does the same.  -f4 displays first 4 in the sequence
# prettifyStopTimes -r WAR_403_V6 -l   # displays only the last sequence;
# prettifyStopTimes -r WAR_403_V6 -h   # doesn't print out the headers
# prettifyStopTimes -r WAR_403_V6 -d,  # prints out lines, using a comma as the delimiter

my $optRails = '';
my $optBus   = '';

#my $optFirstEnabled = '';
#my $optLastEnabled  = '';

my $optFirstLength = '';
my $optLastLength  = '';

my $optNoHeader  = '';
my $optDelimiter = '';

Getopt::Long::Configure("bundling");

GetOptions( 'r=s' => \$optRails,
            'b=s' => \$optBus,
#            'f' => \$optFirstEnabled,
            'f' => \$optFirstLength,
            'l' => \$optLastLength,
            'h!' => \$optNoHeader,
            'd=s' => \$optDelimiter,
);

#print "rail: '$optRails', bus: '$optBus', first: '$optFirstLength', last: '$optLastLength', noHeader: '$optNoHeader', delimiter: '$optDelimiter'\n";
#exit;


#if ( $#ARGV < 0)
#{
#    usage();
#}

my $trip_id = $ARGV[0];
my $busRAIL = $ARGV[1];

if ($optRails ne "")
{
    $trip_id = $optRails;
    $busRAIL = "rail";
}
elsif ($optBus ne "")
{
    $trip_id = $optBus;
    $busRAIL = "bus";
}
else
{
    usage();
}



#my ($screenWidth, $screenHeight) = GetTerminalSize();
my $screenHeight = 40;

if ( ( $busRAIL eq "" ) || ( $busRAIL =~ "bus" ) )
{
    $stopsFile     = "google_bus/" . $stopsFile;
    $tripsFile     = "google_bus/" . $tripsFile;
    $stopTimesFile = "google_bus/" . $stopTimesFile;
}
elsif ( $busRAIL =~ /rail/ )
{
    $stopsFile = "google_rail/" . $stopsFile;
    $tripsFile = "google_rail/" . $tripsFile;
    $stopTimesFile = "google_rail/" . $stopTimesFile;    
}
else
{
    usage();
}



my $headersFromFile;

my @headersWeCareAbout;
my @headerArrayFromFile;
my $columns;

open STOPS, $stopsFile or die "Could not open $stopsFile, error: $!\n\n";
$headersFromFile = <STOPS>;
s/,[ ]+/,/g;

@headersWeCareAbout  = ("stop_id","stop_name","zone_id");
@headerArrayFromFile = split(/,/, $headersFromFile);
$columns = {};

returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want


while (<STOPS>)
{
    @details = split(/,/);
#    $stop_ids{ trim($details[ $columns->{stop_id} ] ) } = $details[ $columns->{stop_name} ];
    $stop_ids{ trim($details[ $columns->{stop_id} ] ) } = { "stop_name" => $details[ $columns->{stop_name} ], "zone_id" => $details[ $columns->{zone_id} ] };
    
#    print "ID: $details[ $columns->{stop_id} ], NAME: $details[ $columns->{stop_name} ]\n";
    
}
close STOPS;


open TRIPS, $tripsFile or die "Could not open $tripsFile, error: $!\n\n";

$headersFromFile = <TRIPS>;
s/,[ ]+/,/g;

@headersWeCareAbout  = ("route_id","service_id", "trip_id","direction_id","route_id");
@headerArrayFromFile = split(/,/, $headersFromFile);
$columns = {};

returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want

my $tripHash = {};
while (<TRIPS>)
{
    @details = split(/,/);
    my $trip_id = $details[$columns->{trip_id}];
    $trip_id =~ s/^\s+//;
    $trip_id =~ s/\s+$//;
    
    $trip_ids{ trim($details[$columns->{trip_id}]) } = { "service_id" => $details[ $columns->{service_id}], "direction_id" => trim($details[ $columns->{direction_id}]) , "route_id" => $details[ $columns->{route_id}] };
}

close TRIPS;


#Tests the hash structure to ensure that it's working properly
#for (keys %stop_ids)
#{
#    print "($_)=$stop_ids{$_} \n";
#}

open TIMES, $stopTimesFile or die "Could not open $stopTimesFile, error: $!\n\n";

my $tempStr;
my $string;

my $printCount = 0;

my @array;

$headersFromFile = <TIMES>;
s/,[ ]+/,/g;

@headersWeCareAbout  = ("trip_id","arrival_time", "departure_time","stop_id","stop_sequence");
@headerArrayFromFile = split(/,/, $headersFromFile);
$columns = {};

returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want



while (<TIMES>)
{
        
    @details = ();
    if ( /$trip_id/ )
    {

#        ($a, $b, $c, $d, $e) = split(/,/, $_, 5);
#        $e =~ s/\r\n//;
        
#        chomp($e);  # Remove newline /n
#        chop($e);   # Remove carriage return /r
#        $tempStr = $e;
#        $e = $stop_ids{$d} . " ($d)\n";
#        $d = $tempStr;
#        
#        print "$a -- $d -- $e";
        
        
        @details = split(/,/);
#        $details[0] = $details[0];  # This is the stupidest line you've ever written!
#        $details[4] =~ s/\r\n//;
        
        
        my $seq  = trim($details[$columns->{stop_sequence}]);
        my $stop = trim($details[$columns->{stop_id}]);
        my $arr  = trim($details[$columns->{arrival_time}]);
        my $dep  = trim($details[$columns->{departure_time}]);
        my $trip = trim($details[$columns->{trip_id}]);
        
        
#        $details[3] =~ s/^[ ]*//;
#        $details[3] =~ s/[ ]*$//;
        my $stopNameId = $stop_ids{$stop}->{stop_name} . " (" . trim($stop) . ")";
#        $details[3] = $tempStr;
        
        my $zone_id = trim($stop_ids{$stop}->{zone_id});
        
        my $service_id = $trip_ids{$trip}->{service_id};
        my $dir_id     = $trip_ids{$trip}->{direction_id};
        
        $dir_id =~ s/^\s*//;
        $dir_id =~ s/\s*$//;
        
        my $route_id   = $trip_ids{$trip}->{route_id};
#        $len        = 5 - length($route_id);
        
        
        
        # Let's figure out width of each value and add a few spaces to it.
        
#        $string = $details[0] . " \t" . $details[1] . "\t" . $details[2] . "\t" . $details[3] . "\t " . $service_id . "\t " . $dir_id . "\t" . $route_id . "\t" . $details[4];
        
        my $hash_ref;
        $hash_ref = { trip_id => $trip, arrival_time => $arr, departure_time => $dep, stop_sequence => $seq, service_id => $service_id, direction_id => $dir_id, route_id => $route_id, stop_name => $stopNameId, zone_id => $zone_id };
        
        push(@array, $hash_ref);
        
#        say Dumper($hash_ref);
        
#        $string = join("\t", @details);

#        if ( ($printCount++ % 40) == 0 )
#        {
#            print "\n\n";
#            print "TRIP_ID \tARRIVAL \t DEPART \tSEQ\tDAY\tDIR\tROUTE\tLOCATION (stop_id)\r\n";
#            print "------- \t------- \t--------\t---\t---\t---\t-----\t------------------\r\n";
#        }
#        
#        print $string;
        
        
    }
    
}

close TIMES;


my @sorted = sort { $a->{stop_sequence} <=> $b->{stop_sequence} } @array;

my $text;


if ( $optFirstLength ne "" )
{
#    print "\n\n";
#    print "  TRIP_ID  \t ARRIVAL \t DEPART \tSEQ\tDAY\tDIR\tROUTE\tLOCATION (stop_id)\r\n";
#    print "-----------\t---------\t--------\t---\t---\t---\t-----\t------------------\r\n";

    my $string = $sorted[0];

    $text = sprintf("%-10%s %-11s %-11s, %-5s %-5s %-5s %-7s %-40s", $string->{trip_id}, $string->{arrival_time}, $string->{departure_time}, $string->{stop_sequence}, $string->{service_id}, $string->{direction_id}, $string->{route_id}, $string->{stop_name} );
    print "$text";
    
#    print $string->{trip_id} . " \t" . $string->{arrival_time} . " \t" . $string->{departure_time} . " \t" . $string->{stop_sequence} . " \t" . $string->{service_id} . " \t" . $string->{direction_id} . " \t" . $string->{route_id} . " \t" . $string->{stop_name};

#    print "\r\n\r\n";
    exit;
    
}
elsif ( $optLastLength ne "" )
{
#    print "\n\n";
#    print "TRIP_ID \tARRIVAL \t DEPART \tSEQ\tDAY\tDIR\tROUTE\tLOCATION (stop_id)\r\n";
#    print "------- \t------- \t--------\t---\t---\t---\t-----\t------------------\r\n";
    
    my $string = $sorted[-1];
    
#    print $string->{trip_id} . " \t" . $string->{arrival_time} . " \t" . $string->{departure_time} . " \t" . $string->{stop_sequence} . " \t" . $string->{service_id} . " \t" . $string->{direction_id} . " \t" . $string->{route_id} . " \t" . $string->{stop_name};
    
    $text = sprintf("%-10%s %-11s %-11s, %-5s %-5s %-5s %-7s %-40s", $string->{trip_id}, $string->{arrival_time}, $string->{departure_time}, $string->{stop_sequence}, $string->{service_id}, $string->{direction_id}, $string->{route_id}, $string->{stop_name} );
    print "$text";

#    print "\r\n\r\n";
    exit;
    
}


my $padding = 3;
my @headerTitles = ("TRIP_ID", "ARRIVAL ", "DEPART  ", "SEQ", "DAY", "DIR", "ROUTE", "ZONE", "LOCATION (stop_id)");

foreach my $string (@sorted)
{

    
    if ( ($printCount++ % ($screenHeight-2) ) == 0 )  # Minus 2 because the header is 2 lines tall
    {
        print "\n\n";
#        print "TRIP_ID \tARRIVAL \t DEPART \tSEQ\tDAY\tDIR\tROUTE\tLOCATION (stop_id)\r\n";
#        print "------- \t------- \t--------\t---\t---\t---\t-----\t------------------\r\n";
        
        my $format;
        my $headerString = "";
        
        # print out the header names
        foreach my $header (@headerTitles)
        {
            
            if ( $header eq "TRIP_ID" )
            {
                $padding = 7;
            }
            else
            {
                $padding = 3;
            }
            
            $format = "%-" . (length($header) + $padding) . "s";
            $text = sprintf($format, $header);
            $headerString .= $text;
        }
        
        print $headerString . "\n";
        $headerString = "";
        
        # print out the header divider (the dashes)
        foreach my $header (@headerTitles)
        {
            
            if ( $header eq "TRIP_ID" )
            {
                $padding = 7;
            }
            else
            {
                $padding = 3;
            }
            
            $format = "%-" . (length($header) + $padding) . "s";
            $text = sprintf( $format, "-" x length($header) );
            $headerString .= $text;
        }
        
        print $headerString . "\n";
        $headerString = "";
        
    }
    
    
#    print $string->{trip_id} . " \t" . $string->{arrival_time} . " \t" . $string->{departure_time} . " \t" . $string->{stop_sequence} . " \t" . $string->{service_id} . " \t" . $string->{direction_id} . " \t" . $string->{route_id} . " \t" . $string->{stop_name};
    
    
    my @keyValues = ("trip_id", "arrival_time", "departure_time", "stop_sequence", "service_id", "direction_id", "route_id", "zone_id", "stop_name");
    my $format;
    $text = "";
    
    my $count = 0;
    foreach my $key (@keyValues)
    {
        
        if ( $key eq "trip_id" )
        {
            $padding = 7;
        }
        else
        {
            $padding = 3;
        }
        
        $format = "%-" . (length($headerTitles[$count++]) + $padding) . "s";
        $text .= sprintf( $format, $string->{$key} );
    }
    
    print "$text\r\n";
    
}

print "\r\n\r\n";

