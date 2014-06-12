#!/usr/bin/perl


# --==  USE Section  ==--
use strict;

#use Data::Dumper;
#use feature 'say';

use Getopt::Long;


# --==  Declaration Section  ==--

my $stopTimesFile = "stop_times.txt";
my $stopsFile     = "stops.txt";
my $tripsFile     = "trips.txt";
my $shapesFile    = "shapes.txt";
my $routesFile    = "routes.txt";

$SIG{INT} = $SIG{TERM} = $SIG{HUP} = 'CLEANUP';


my $KMLHEADER = <<END;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
    <name>NAMEGOESHERE.kml</name>
    <Style id="LineStyleROUTESHORTNAMEGOESHERE">
        <LabelStyle>
            <color>00000000</color>
            <scale>0</scale>
        </LabelStyle>
        <LineStyle>
            <color>FF0000FF</color>
            <width>5</width>
        </LineStyle>
        <PolyStyle>
            <color>00000000</color>
            <outline>0</outline>
        </PolyStyle>
    </Style>
    <Placemark id="ID_00ROUTESHORTNAMEGOESHERE">
        <name>Route ROUTESHORTNAMEGOESHERE</name>
        <Snippet maxLines="0"></Snippet>

        <styleUrl>#LineStyleROUTESHORTNAMEGOESHERE</styleUrl>
        <MultiGeometry>
            
END

my $KMLHEADER_MINUS_PLACEMARK = <<END;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document>
        <name>NAMEGOESHERE.kml</name>
        <Style id="LineStyleROUTESHORTNAMEGOESHERE">
            <LabelStyle>
                <color>00000000</color>
                <scale>0</scale>
            </LabelStyle>
            <LineStyle>
                <color>FF0000FF</color>
                <width>5</width>
            </LineStyle>
            <PolyStyle>
                <color>00000000</color>
                <outline>0</outline>
            </PolyStyle>
        </Style>
END

my $KMLFOOTER_MINUS_PLACEMARK = <<END;
    </Document>
</kml>
END

my $KMLFOOTER = <<END;
        </MultiGeometry>
    </Placemark>
</Document>
</kml>

END

my $optRoute_id;

my $optRail;
my $optBus;

my $optSplit;
my $optTimeStamp;

my $optFilename;
my $optCompress;

my $optStops;

my $routeShortName;
my $routeLongName;

my $routeID;

my %tripShapes;
my %coordinates;

my @trips;
my @shapes;

# --==  BEGIN HERE 644  ==--

Getopt::Long::Configure("bundling");


# A route_id must be given so this script can figure out which shapes to use in building the KML file


GetOptions(
    'r=s' => \$optRail,
    'b=s' => \$optBus,
    'route=s' => \$optRoute_id,
    'split' => \$optSplit,
    'timestamp' => \$optTimeStamp,
    'o=s' => \$optFilename,
    'z'   => \$optCompress,
    'stops' => \$optStops,
#'b=s' => \$optBus,
#'f' => \$optFirstEnabled,
#'f' => \$optFirstLength,
#'l' => \$optLastLength,
#'h!' => \$optNoHeader,
#'d=s' => \$optDelimiter,
);


if ( $optCompress )
{
    # If Compress is turned on, then splitting and timestamps make absolutely no sense.
    undef $optSplit;
    undef $optTimeStamp;
}


$optRoute_id = $optRail if ( $optRail );
$optRoute_id = $optBus  if ( $optBus  );

if ( $optRoute_id && ($optRail || $optBus) )
{
    main();
}
else
{
    usage();
}



# --==  SUBROUTINES  ==--

sub usage
{
    print "\n";
    print "Usage:";
    print "\tperl shapeToKML.pl --route=10678 -r\n";
    print "\t -r\t Searches rails for route_id\n";
    print "\t -b\t Searches buses for route_id\n";
    print "\t --route\t The route_id to find associated KML files\n";
    print "\t --split\tSplit each shape_id into its own KML\n";
    print "\t --timeStamp\tBreak coordinates into points with timeStamp, allows animation of trip.\n";
    print "\t -z\tCompresses the coordinates in shapes.txt by removing all duplicates.\n";
    print "\t -o\tSpecify new output KML file instead of the default one\n";
    
    print "\n";
    print "Examples:\n";
    print "\tperl shapeToKML.pl -r --route WAR --split -o WAR.kml\n";
    print "\t\t - Generates WAR.kml from route WAR, splitting each shape into Placemarks\n\n";
    print "\tperl shapeToKML.pl -b --route 10684 --timestamp\n";
    print "\t\t - Generates 50.kml (found route_short_name from 10684), splitting each coordinate into a time stamped point\n";
    print "\tperl shapeToKML.pl -b --route 1\n";
    print "\t\t - Generates 1.kml, combining all\n";
    print "\n\n";
}


sub main
{
    
    
    if ( $optStops )
    {

        my $stopsHashRef;
        my $routesHashRef;
        my $tripsHashRef;
        my $shapesHashRef;
        my $stopTimesHashRef;
        my $tripsIDHashRef;

        $routesHashRef = populateRoutesHash( fullPathFor("routes.txt")    );
        findRouteForRoute_X_WithRouteHash_Y( $optRoute_id, $routesHashRef );
        
        ($tripsHashRef, $tripsIDHashRef) = populateTripsHash( fullPathFor("trips.txt" ), $routesHashRef );
        
        $shapesHashRef = populateShapesHash  ( fullPathFor("shapes.txt"), $tripsHashRef ); # %tripsHashRef is organized by $shapeIDs, %tripsIDHashRef by $tripIDs
        $stopsHashRef = populateStopsHash( fullPathFor("stops.txt" ) );
        
        $stopTimesHashRef = populateStopTimesHashForFilename_X_WithStopsHash_Y_AndTripsIDHash_Z( fullPathFor("stop_times.txt"), $stopsHashRef, $tripsIDHashRef);
#        $stopTimesHashRef = {test => "Dummy"};
        
        # Why no start with V and W instead of X?  V and W are stupid variable names
        generateKMLForStopsWithStopHash_X_WithRoutesHash_Y_WithTripsHash_Z_AndShapesHash_A_AndStopTimesHash_B($stopsHashRef, $routesHashRef, $tripsHashRef, $shapesHashRef, $stopTimesHashRef);
        
        # V:  V here with the twins, W.
        # W:  Hello.  Hi.
        # V:  We just wanted to say there's nothing with using us as variables.  Many fine programmers use us as such.  Perhaps that's part of the reason...
        # V:  Oh, and you're stupid, stupid!
        
    }
    else
    {
        
        loadRoutes();
        loadTrips();
        
        loadShapes();
        
    }
    
    
#    if ( $optTimeStamp )
#    {
#        loadShapesWithTimeStamps();
#    }
#    else
#    {
#        loadShapes();
#    }
    
}


sub beginSplitPlacemarkForName_X_WithTripCount_Y_AndTrips_Z
{
    
    if ( $_[0] && $_[1] && $_[2] )
    {
        beginSplitPlacemark($_[0], $_[1], $_[2]);
    }  # if ( $_[0] && $_[1] && $_[2] )

}  # sub beginSplitPlacemarkForName_X_WithTripCount_Y_AndTrips_Z


sub beginSplitPlacemark
{
    
    my $name = $_[0];
    my $tripCount = $_[1];
    my $trips = $_[2];
    
    if ( !$name )
    {
        print "Incorrect number of parameters passed to generateSplitPlacemark\n";
        return;
    }
    
    my $PLACEMARK = <<END;
        <Placemark>
            <name>shape_id NAMEGOESHERE ($tripCount trips)</name>
            <description> trip_ids: $trips </description>
            <styleUrl>#LineStyleROUTESHORTNAMEGOESHERE</styleUrl>
            <LineString>
                <coordinates>
END
    
    $PLACEMARK =~ s/NAMEGOESHERE/$name/;
    $PLACEMARK =~ s/ROUTESHORTNAMEGOESHERE/$routeShortName/;
    
    print OUTPUT $PLACEMARK;
    
}


sub endSplitPlacemark
{
    my $PLACEMARK = <<END;
        </Placemark>
END
    
    print OUTPUT $PLACEMARK;
}

sub generateTimeStampedPlacemark
{
    
    my $whenStr   = $_[0];
    my $pointsStr = $_[1];
    my $seq       = $_[2];
    
    if ( !$whenStr || !$pointsStr || !$seq)
    {
        print "Incorrect number of parameters passed to generatePlacemark";
        return;
    }
    
    my $PLACEMARK = <<END;
<Placemark>
    <name>Sequence #$seq</name>
    <description>($pointsStr)</description>
    <TimeStamp>
        <when>$whenStr</when>
    </TimeStamp>
    <styleUrl>#LineStyle$routeShortName</styleUrl>
    <Point>
        <coordinates>$pointsStr</coordinates>
    </Point>
</Placemark>
END
    
#    $PLACEMARK =~ s/TIMEGOESHERE/$whenStr/;
#    $PLACEMARK =~ s/ROUTESHORTNAMEGOESHERE/$routeShortName/;
#    $PLACEMARK =~ s/COORDINATESGOHERE/$pointsStr/;
    
    print OUTPUT $PLACEMARK;
    
}


sub generateKMLFooter
{
    
    print OUTPUT $KMLFOOTER;
    
}

sub generateKMLFooterMinusPlacemark
{
    
    print OUTPUT $KMLFOOTER_MINUS_PLACEMARK;
    
}


sub createOutputFile
{
    my $filename;
    if ( $optFilename )
    {
        $optFilename =~ s/\.kml$//;  # Remove any trailing '.kml' from the file name
        $filename = $optFilename; # . "_" . $_[0];
    }
    else
    {
#        $filename = $optRoute_id;
        $filename = $routeShortName;
    }
    
    my $output = $filename . ".kml";
    open OUTPUT, ">$output" or die "Could not open $output for writing.  Err: $!\n";
    
}


sub generateKMLHeaderMinusPlacemark
{
    
    my $tempHeader = $KMLHEADER_MINUS_PLACEMARK;
    
    $tempHeader =~ s/NAMEGOESHERE/$routeShortName/;
    $tempHeader =~ s/ROUTESHORTNAMEGOESHERE/$routeShortName/g;
    
    print OUTPUT $tempHeader;
    
}

sub generateKMLHeader
{
    
#    my $filename;
#    
#    if ( $optSplit )
#    {
#        $filename = $optRoute_id; # . "_" . $_[0];
#    }
#    else
#    {
#        $filename = $optRoute_id;
#    }
#    
#    my $output = $filename . ".kml";
#    open OUTPUT, ">$output" or die "Could not open $output for writing.  Err: $!\n";
    
    my $tempHeader = $KMLHEADER;
    
    $tempHeader =~ s/NAMEGOESHERE/$routeShortName/;
    $tempHeader =~ s/ROUTESHORTNAMEGOESHERE/$routeShortName/g;
    
    print OUTPUT $tempHeader;
}


sub loadShapesWithTimeStamps
{
    
    print "NO TIMESTAMPS FOR YOU!  1 YEAR!\n";
    
    exit(1);
    
    my $rail = "google_rail/";
    my $bus  = "google_bus/";
    
    my $dir;
    
    if ( $optRail )
    {
        $dir = $rail;
    }
    elsif ( $optBus )
    {
        $dir = $bus;
    }
    
    $shapesFile = $dir . $shapesFile;
    open SHAPES, $shapesFile or die "Could not open $shapesFile.  Err: $!\n";
    
    my $headersFromFile = <SHAPES>;
    $headersFromFile =~ s/,[ ]+/,/g;
    
    my @headersWeCareAbout  = ("shape_pt_lon","shape_pt_lat","shape_id","shape_pt_sequence");
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    # KML order (lon, lat, alt).  Shape data order: (lat, lon)
    my $fileLength = `wc -l $shapesFile`;
    $fileLength =~ s/^\s*(\d+).*?$/\1/;
    
    my $count = 1;
    
    my %shapeData;
    my $output;
    
    while (<SHAPES>)
    {
        
        my @arr = split(",");
        
        my $shape_id = @arr[ $columns->{shape_id} ];
        trim($shape_id);
        
        if ( ( $count % 100 ) == 0 )
        {
            #            print "\b" x length($output);
            #            $output = sprintf("Reading line... %7s out of %7s", $., $fileLength);
            #            print $output;
        }
        
        if ( grep(/$shape_id/, @shapes) )
        {
            
            #            print "shape_id: $shape_id\n";
            
            my $lat      = @arr[ $columns->{shape_pt_lat} ];
            my $lon      = @arr[ $columns->{shape_pt_lon} ];
            my $seq      = @arr[ $columns->{shape_pt_sequence} ];
            
            trim($lat);
            trim($lon);
            trim($seq);
            
            push ( @{ $shapeData{$shape_id} }, {lat => $lat, lon => $lon, alt => "0", seq => $seq} );
        }
        
        $count++;
        
    }
    
    close SHAPES;
    
    
    # %shapeData contains all the information that we need to generate a KML file
    # Each key in %shapeData will be it's own LineString in the MultiGeometry tag
    
    # Options:
    #   -s      Splits the KML into multiple shape_ids.  Either shape_id will be contained within a folder
    #   -ts     Splits the long list of coordinates in <LineString> into individual <Point> tags with <TimeStamp>
    #           If neither of this options are used, each shape_id is put in its own <LineString>
    
    #   -z      Mutably exclusive to -ts and -s.  This ensures the KML does not contain multiple coordinates
    
    # No options:
    # <Placemark>
    #   <name>all shapes</name>
    #   <description>Contains the following shapes: XXX, YYY, ZZZ, etc.</description>
    #   <MultiGeometry>
    #      <LineString>
    #         <coordinates> ... </coordinates>
    #      </LineString>
    #   </MultiGeometry>
    # </Placemark>
    
    # Just -s option:  no multiGeometry needed
    #    <name>shape_id</name>
    #    <Placemark>
    #       <name>shape_id</name>
    #       <LineString>
    #       </LineString>
    #    </Placemark>
    #    <Placemark>
    #       <name>shape_id</name>
    #       <LineString>
    #       </LineString>
    #    </Placemark>

    
    my $filename;
    if ( $optSplit )
    {
        $filename = $optRoute_id . "_" . $_[0];
    }
    else
    {
        $filename = $optRoute_id;
    }
    
    my $output = $filename . ".kml";
    open OUTPUT, ">$output" or die "Could not open $output for writing.  Err: $!\n";
    
    createOutputFile();
    
    if ( !$optSplit )  # if -s option was not specified
    {
        generateKMLHeader();
    }
    else
    {
        generateKMLHeaderMinusPlacemark();  # Creates a new KML file ading $shapeKey to the filename
    }
    
    
    foreach my $shapeKey (sort keys %shapeData)
    {
        # $shapeKey contains each shape_id related to route_id
        # $shapeData{$shapeKey} is an array that contains all the points we need to write
        
        # Sort the data by the sequence
        print "$shapeKey\n";
        #        foreach my $points (sort { $shapeData{$shapeKey}[$a]->{seq} <=> $shapeData{$shapeKey}[$b]->{seq} } @{ $shapeData{$shapeKey} } )
        my @arr = @{ $shapeData{$shapeKey} };
        #        foreach my $points ( @{ $shapeData{$shapeKey} } )
                
        my $date = time();  # Returns the current time in seconds
        
        foreach my $points ( sort { $a->{seq} <=> $b->{seq} } @arr )
        {
        
            my $lat = $points->{lat};
            my $lon = $points->{lon};
            
            my $data = $lon . "," . $lat;
            
            my ($sec, $min, $hour, $day, $mon, $year) = localtime($date);
            my $timeStr = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", 1900+$year, 1+$mon, $day, $hour, $min, $sec);

            
#            generateTimeStampedPlacemark($timeStr, $data);
            
            $date += 5;
            
        }
        
#        if ( $optSplit )
#        {
#            generateKMLFooterMinusPlacemark();  # End the tags and close the KML file
#        }
        
    } # foreach my $shapeKey (keys %shapeData)

    if ( !$optSplit )
    {
        generateKMLFooterMinusPlacemark();
    }
    else
    {
        generateKMLHeaderFooterPlacemark();  # Creates a new KML file adding $shapeKey to the filename
    }
    
    close OUTPUT;
    
}

sub loadShapes
{
    

    $shapesFile = addDirectory($shapesFile);
    open SHAPES, $shapesFile or die "Could not open $shapesFile.  Err: $!\n";
    
    my $headersFromFile = <SHAPES>;
    $headersFromFile =~ s/,[ ]+/,/g;
    
    my @headersWeCareAbout  = ("shape_pt_lon","shape_pt_lat","shape_id","shape_pt_sequence");
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    # KML order (lon, lat, alt).  Shape data order: (lat, lon)
    my $fileLength = `wc -l $shapesFile`;
    $fileLength =~ s/^\s*(\d+).*?$/\1/;
    
    my $count = 1;
    my $i = 0;

    my %shapeData;
    my $output;
    
    while (<SHAPES>)
    {
        
        my @arr = split(",");

        my $shape_id = @arr[ $columns->{shape_id} ];
        trim($shape_id);

        if ( ( $count % 100 ) == 0 )
        {
#            print "\b" x length($output);
#            $output = sprintf("Reading line... %7s out of %7s", $., $fileLength);
#            print $output;
        }
        
        if ( grep(/$shape_id/, @shapes) )
        {

#            print "shape_id: $shape_id\n";
            
            my $lat      = @arr[ $columns->{shape_pt_lat} ];
            my $lon      = @arr[ $columns->{shape_pt_lon} ];
            my $seq      = @arr[ $columns->{shape_pt_sequence} ];
            
            trim($lat);
            trim($lon);
            trim($seq);

#            if ( $optCompress )
#            {
#                my $coordStr = "$lon;$lat";
#                if ( !$coordinates{$coordStr} )
#                {
#                    # Only push coordinates that aren't repeated
#                    push ( @{ $shapeData{$shape_id} }, {lat => $lat, lon => $lon, alt => "0", seq => $seq} );
#                    $i++;
#                }
#                
#                $coordinates{$coordStr} = 1;
#            }
#            else
#            {
                $i++;
                push ( @{ $shapeData{$shape_id} }, {lat => $lat, lon => $lon, alt => "0", seq => $seq} );
#            }
            
        }
        
        $count++;
        
    } # while (<SHAPES>)
    
    print "Stored coordinates: $i\n";
    
    close SHAPES;
    
    
    
    if ( $optCompress )
    {
        
        # When asking for compressing the data points, we have to intelligently remove duplicate coordinates.
        # Assumption:  each shape is a continuous function
        # Find the shape with the most points.  Nulling out any duplicate points from the remaining shapes.
        # Find the next largest shapes and nulling out any duplicate points from the remaining shapes.
        # Continue on until all the shapes have been exhaustive.
        
#        my @s = sort {length $a <=> length $b} 

        my @s = reverse sort { $#{ $shapeData{$a} } <=> $#{ $shapeData{$b} } } keys %shapeData;
        
        # THEN! go through the arrays and every time a null coordinate is encountered end the old </LineString> and start the next a new one.
        
        print "@s\n";

        # Prints out a visual check of the output
        foreach my $key (@s)
        {
            print "   $key - " . $#{ $shapeData{$key} } . "\n";
        }

        
        foreach my $key (@s)
        {

            print "\nUninterrupted count for: $key\n";
            my $uninterrupted = 0;
            my @container = ();
            
#            foreach my $hash ( @{ $shapeData{$key} } )
            for my $index (0 .. $#{ $shapeData{$key} } )
            {
                my $hash = $shapeData{$key}[$index];
                
                my $lat = $hash->{lat};
                my $lon = $hash->{lon};
                my $seq = $hash->{seq};
                my $alt = $hash->{alt};
                
                my $coordStr = "$lon;$lat";
                if ( !$coordinates{$coordStr} )
                {
#                    push ( @{ $shapeData{$shape_id} }, {lat => $lat, lon => $lon, alt => "0", seq => $seq} );
                    $coordinates{$coordStr} = 1;
                    $uninterrupted++;
                }
                else
                {
                    if ( $uninterrupted > 0 )
                    {
                        my $message = sprintf("A run of %4s was broken at index %4d (%s)\n", $uninterrupted, $index, $coordStr );
                        push(@container, "      $message");
                    }
                    
#                    print "Found $uninterrupted contiguous coordinates.\n" if ( $uninterrupted != 0 );
                    $uninterrupted = 0;
                    $shapeData{$key}[$index] = "0";
                }
                
            }  #foreach my $hash ( @{ $shapeData{$key} } )
            
            my $message = sprintf("A run of %4s was broken at index %4d\n", $uninterrupted, $#{$shapeData{$key} } );
            push(@container, "      $message") if ( $uninterrupted > 0 );
            
            if ( $#container < 0 )
            {
                print "   $key contains no unique coordinates\n";
            }
            else
            {
                print "   Found " . ($#container+1) . " groups of contiguous coordinates.\n @container\n";
            }
            
        } # foreach my $key (@s)

        exit(1);

    }  # if ( $optCompress )
    
    
    print "FIN!\n";
    
    
    
    
    # TimeStamp
    # <Folder>
    #    <Placemark>
    #       <name> blah </name>
    #       <description> blah </name>
    #    </Placemark>
    # </Folder>
    
    
    # %shapeData contains all the information that we need to generate a KML file
    # Each key in %shapeData will be it's own LineString in the MultiGeometry tag
    
    createOutputFile();  # Opens a file for output
    
    
    if ( $optSplit || $optTimeStamp )
    {
        generateKMLHeaderMinusPlacemark();  # Creates a new KML file ading $shapeKey to the filename
    }
    else
    {
        print "HERE\n";
        generateKMLHeader();
    }
    
    
    foreach my $shapeKey (sort keys %shapeData)
    {
     
        if ( $optSplit && !$optTimeStamp )
        {
            my $string = join ", ", @{ $tripShapes{$shapeKey} };
            my $size = $#{ $tripShapes{$shapeKey} } + 1;
            
            beginSplitPlacemark($shapeKey, $size, $string);
        }
        
        
        # $shapeKey contains each shape_id related to route_id
        # $shapeData{$shapeKey} is an array that contains all the points we need to write
        
        # Sort the data by the sequence
#        print "$shapeKey\n";
        
        my @arr = @{ $shapeData{$shapeKey} };

        # TimeStamp - ignore LineString and tab line
        # Split     - ignore tab line, print LineString
        # None      - print tab line
        
        if ( $optTimeStamp )
        {
            # TimeStamp
            
            print OUTPUT "<Folder>\n\t<name>shape_id: $shapeKey</name>\n";
        }
        elsif ( !$optSplit )
        {
            print OUTPUT "\t\t\t<LineString>\n\t\t\t\t<coordinates>\n\t\t\t\t\t";            
        }
#        else
#        {
#            # None
#            print OUTPUT "\t\t\t\t\t";
#        }
        
#        print OUTPUT "\t\t\t<LineString>\n\t\t\t\t<coordinates>\n\t\t\t\t\t" if (!$optSplit);
#        print OUTPUT "\t\t\t\t\t" if ( $optSplit && !$optTimeStamp );
        
        
        my $date = time();
        
        foreach my $points ( sort { $a->{seq} <=> $b->{seq} } @arr )
        {
            my $lat = $points->{lat};
            my $lon = $points->{lon};
            my $alt = $points->{alt};
            
            my $seq = $points->{seq};
            
#            my $shape_id = $points->{shape_id};
            
            if ( $optTimeStamp )
            {
                my $lat = $points->{lat};
                my $lon = $points->{lon};
                
                my $data = $lon . "," . $lat;
                
                my ($sec, $min, $hour, $day, $mon, $year) = localtime($date);
                my $timeStr = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", 1900+$year, 1+$mon, $day, $hour, $min, $sec);
                
                generateTimeStampedPlacemark($timeStr, $data, $seq);
                
                $date += 30;
            }
            else
            {
                print OUTPUT "$lon,$lat,$alt ";
            }
            
        }

        
        if ( !$optTimeStamp )
        {
            print OUTPUT "\n\t\t\t\t</coordinates>\n\t\t\t</LineString>\n";
        }
        elsif ( $optTimeStamp )
        {
            print OUTPUT "</Folder>\n";
        }
        
        
        if ( $optSplit )
        {
            endSplitPlacemark();  # End the tags and close the KML file
        }
        
    } # foreach my $shapeKey (keys %shapeData)
    
    
    if ( $optSplit || $optTimeStamp )
    {
        generateKMLFooterMinusPlacemark();
    }
    else
    {
        generateKMLFooter();
    }
    
    close OUTPUT;
    
}

sub addDirectory
{
    my $filename = $_[0];
    
    if ( $filename )
    {
        
        my $rail = "google_rail/";
        my $bus  = "google_bus/";
        
        my $dir;
        
        if ( $optRail )
        {
            $dir = $rail;
        }
        elsif ( $optBus )
        {
            $dir = $bus;
        }
        
        return $dir . $filename;
    }
    else
    {
        return;
    }
    
}

sub loadRoutes
{
    
    $routesFile = addDirectory($routesFile);
    if ( !$routesFile )
    {
        exit(1);
    }
    
    open ROUTES, $routesFile or die "Could not open $routesFile.  Err: $!\n";
    
    my $headersFromFile = <ROUTES>;
    $headersFromFile =~ s/,[ ]+/,/g;
    
    my @headersWeCareAbout  = ("route_id","route_short_name","route_long_name");
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
    while (<ROUTES>)
    {
        
        my @arr = split(/,/);
        
        my $route_id = $arr[ $columns->{route_id} ];
        my $route_short_name = $arr[ $columns->{route_short_name} ];
        my $route_long_name  = $arr[ $columns->{route_long_name} ];
        
        if ( $route_id =~ /\b$optRoute_id\b/ )
        {
            print "'$optRoute_id' matched route_id : $route_id, $route_short_name, $route_long_name\n";
            $routeID        = $route_id;
            $routeShortName = $route_short_name;
            $routeLongName  = $route_long_name;
            last;
        }
        elsif ( $route_short_name =~ /\b$optRoute_id\b/ )
        {
            print "'$optRoute_id' matched route_short_name : $route_id, $route_short_name, $route_long_name\n";
            $routeID        = $route_id;
            $routeShortName = $route_short_name;
            $routeLongName  = $route_long_name;
            last;
        }
        
    }
    
    close ROUTES;    
    
    if ( !$routeShortName || !$routeID || !$routeLongName )
    {
        print "Unable to find $optRoute_id in GTFS.  Sorry.\n";
        exit(1);
    }
    
}

sub loadTrips
{
    
    $tripsFile = addDirectory($tripsFile);
    
#    $tripsFile = $dir . $tripsFile;
    open TRIPS, $tripsFile or die "Could not open $tripsFile.  Err: $!\n";
    
    my $headersFromFile = <TRIPS>;
    $headersFromFile =~ s/,[ ]+/,/g;
    
    my @headersWeCareAbout  = ("route_id","trip_id","shape_id");
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);  #columns is a hash reference containing the information we want
    
#    my $shapeList;
    while (<TRIPS>)
    {
        
        next if ( !/^\s*?$routeID/ );
        
#        print;
        
        my @arr = split(",");
        
        my $route_id = @arr[ $columns->{route_id} ];
        my $shape_id = @arr[ $columns->{shape_id} ];
        my $trip_id  = @arr[ $columns->{trip_id} ];
        
        trim($route_id);
        trim($shape_id);
        trim($trip_id);

        
        if ( !grep( /$shape_id/, @shapes) )
        {
#            print "Pushing... $shape_id\n";
            push(@shapes, $shape_id);
        }
        push( @{ $tripShapes{$shape_id} }, $trip_id );
        
    }
    
    close TRIPS;
    
#    foreach my $shapes ( keys %tripShapes )
#    {
#        my $string = join ", ", @{ $tripShapes{$shapes} };
#        my $size = $#{ $tripShapes{$shapes} } + 1;
#        print "$shapes ($size trips)\n";
#        print "\t$string\n";
#    }

    
    print "Route ID: $routeID (shortName: $routeShortName, longName: $routeLongName)\n";
#    foreach my $shape (@shapes)
#    {
#        print "\t$shape\n";
#    }
    
    
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
    
}  # sub returnColumnsWeCareAbout


sub CLEANUP
{

    print "\n\nCaught Signal Handler, Gracefully Aborting\n";
    close OUTPUT;
    
    exit(1);
}


sub fullPathFor
{
    
    my $filename;
    
    # First, check there was a directory based from the command line and, if so, if that directory contains the file we're looking for
#    if ( $optBusDirectory )
#    {
#        $filename = "$optBusDirectory/$_[0]";
#        if ( -e $filename )
#        {
#            # We found our filename.  Full stop.  Return the full path and filename.
#            return $filename;
#        }
#    }
    
    
    # No directory was giving.  So, we'll try looking in google_bus and the current directory.
    $filename = "google_bus/$_[0]"  if ( $optBus );
    $filename = "google_rail/$_[0]" if ( $optRail );
    
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


sub populateStopsHash
{
    
    my $filename = $_[0];
    my %thisHash;
    
    open STOPS, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <STOPS>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("stop_id", "stop_name", "stop_lon", "stop_lat");
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
    
    return \%thisHash;
    
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
    
    close ROUTES;
    return \%thisHash;
    
}


sub populateShapesHash
{
    
    my $filename = $_[0];
    my %tripsHash = %{ $_[1] };
    
    my %thisHash;
    
    open SHAPES, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <SHAPES>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("shape_id", "shape_pt_lat", "shape_pt_lon", "shape_pt_sequence");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $shapeID;
    my $shapeLat;
    my $shapeLon;
    my $shapeSeq;
    
    my $hashRef;
    
    while (<SHAPES>)
    {
        my @line = split(/,/);
        
        $shapeID     = $line[ $columns->{shape_id}          ];
        
        # The %tripsHash is built using shapeID for the key.  If the current shapeID can't be found in %tripsHash, don't bother storing it.
        if ( !$tripsHash{$shapeID} )
        {
            next;
        }
        
        # If we're here, $shapeID was found in %tripsHash so let's store it all!
        $shapeLat    = $line[ $columns->{shape_pt_lat}      ];
        $shapeLon    = $line[ $columns->{shape_pt_lon}      ];
        $shapeSeq    = trim($line[ $columns->{shape_pt_sequence} ]);
        
        $hashRef = { shape_id => $shapeID, shape_pt_lat => $shapeLat, shape_pt_lon => $shapeLon, shape_pt_sequence => $shapeSeq };
        push( @{ $thisHash{ $shapeID } }, $hashRef);
        
    }
    
    close SHAPES;

    return \%thisHash;
    
}


sub populateStopTimesHashForFilename_X_WithStopsHash_Y_AndTripsIDHash_Z
{
    
    my $filename  = $_[0];       # X
    my %stopsHash = %{ $_[1] };  # Y
    my %tripsHash = %{ $_[2] };  # Z
    
    my %thisHash;
    
    open STOPTIMES, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <STOPTIMES>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("stop_id", "trip_ip");  # Fields not used: arrival_time, departure_time, stop_sequence
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
#    my $tripList = "";
##    my $count = 1;
#    foreach my $tripID (keys %tripsHash)
#    {
##        print($count++ . ": $tripID\n");
#        $tripList .= "$tripID;";
#    }
    
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
        
#        my $dirID    = $tripsHash{$tripID}->{direction_id};
#        my $routeID  = $tripsHash{$tripID}->{route_id};
        
        #        print "RouteID: $routeID, DirID: $dirID\n";
        #        print $_;
        #
        
        my $hashRef = { stop_id => $stopID, stop_name => $stopName, lat => $stopLat, lon => $stopLon, trip_id => $tripID };
        push( @{ $thisHash{$tripID} }, $hashRef );
        
#        if ( !$thisHash{$routeID}{$dirID}{$stopID} )
#        {
#            my $hashRef = { stop_id => $stopID, stop_name => $stopName, lat => $stopLat, lon => $stopLon, trip_id => $tripID };
#            #            push(@{ $thisHash{$routeID}{$dirID}{$stopID} }, $hashRef);
#            $thisHash{$routeID}{$dirID}{$stopID} = $hashRef;
#        }
        
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


sub populateTripsHash
{
    
    my $filename = $_[0];
    my %routesHash = %{ $_[1] };
    
    my %thisHash;
    my %tripIDHash;
    
    open TRIPS, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <TRIPS>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("trip_id", "route_id", "direction_id","shape_id");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $tripID;
    my $routeID;
    my $dirID;
    my $shapeID;
    
    my $hashRef;
    
    while (<TRIPS>)
    {
        my @line = split(/,/);
        
        $routeID  = $line[ $columns->{route_id} ];  # routeID needs to contain a value for the optRouteSelection part to work
        
        if ( $optRoute_id )
        {
            if ( $optRoute_id !~ /$routeID/ )
            {
                next;  # If the route selected does not match $routeID, read the next line
            }
        }
        
        $tripID   = $line[ $columns->{trip_id}      ];
        $dirID    = $line[ $columns->{direction_id} ];
        $shapeID  = trim($line[ $columns->{shape_id}     ]);
        
        # We're going to store the data in trips based on the shape_id.  Each shape_id will contain an array of trips.
        
        $hashRef = { trip_id => $tripID, route_id => $routeID, direction_id => $dirID, shape_id => $shapeID };
        $tripIDHash{ $tripID } = 1;
#        $thisHash{ $tripID } = $hashRef;
       
        push( @{ $thisHash{ $shapeID } }, $hashRef );
        
    }
    
    close TRIPS;
    
    return (\%thisHash, \%tripIDHash);
    #    return \%stopsHash;
    
}

sub findRouteForRoute_X_WithRouteHash_Y
{
    
    my $routeSelection = $_[0];
    
    # This is redundant, but it still doesn't hurt to check
    if ( !$routeSelection )
    {
        # $optRouteSelection was never set, so there's nothing to do here
        return;
    }
    
    
    my %routesHash = %{ $_[1] };
    
    if ( $routesHash{$routeSelection} )
    {
        # If $optRouteSelection exists in $routesHash, everything is right in the world!  Return $optRouteSelection
        
        $routeShortName = $routesHash{$routeSelection}->{route_short_name};
        $routeLongName  = $routesHash{$routeSelection}->{route_long_name};
        
        return $routeSelection;
    }
    else
    {
        foreach my $key (%routesHash)
        {
            if ( $routesHash{$key}->{route_short_name} =~ /$routeSelection/ )
            {
                $routeSelection = $key;
                return $key;
            }
        }
    }
    
}


sub returnKMLStopHeader
{
    
my $KMLSTOPSHEADER = <<END;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>NAMEGOESHERE.kml</name>

    <Style id="Direction0">
      <IconStyle>
        <Icon>
          <href>direction0Tag.png</href>
        </Icon>
      </IconStyle>
    </Style>

    <Style id="Direction1">
      <IconStyle>
        <Icon>
          <href>direction1Tag.png</href>
        </Icon>
      </IconStyle>
    </Style>

    <Style id="StopIDs">
      <IconStyle>
        <Icon>
          <href>stopidTag.png</href>
        </Icon>
      </IconStyle>
    </Style>

    <Style id="LineStyleROUTESHORTNAMEGOESHERE">
      <LabelStyle>
        <color>00000000</color>
        <scale>0</scale>
      </LabelStyle>
      <LineStyle>
        <color>FF0000FF</color>
        <width>5</width>
      </LineStyle>
      <PolyStyle>
        <color>00000000</color>
        <outline>0</outline>
      </PolyStyle>
    </Style>

END

    return $KMLSTOPSHEADER;
    
}

#        <Placemark id="ID_00ROUTESHORTNAMEGOESHERE">
#<name>Route ROUTESHORTNAMEGOESHERE</name>
#<Snippet maxLines="0"></Snippet>
#<styleUrl>#LineStyleROUTESHORTNAMEGOESHERE</styleUrl>
#<MultiGeometry>

sub populateStopPairHash
{
    
    my $filename = $_[0];
    my %thisHash;
    
    open STOPPAIR, $filename or die "Could not open $filename.  $!\n";
    
    my $headersFromFile = <STOPPAIR>;
    my @headerArrayFromFile = split(/,/, $headersFromFile);
    my @headersWeCareAbout = ("route_id","stop_id","opposite_stop_id","distance_ft");
    my $columns = {};
    
    returnColumnsWeCareAbout(\@headersWeCareAbout, \@headerArrayFromFile, $columns);
    
    my $routeID;
    my $stopID;
    my $oppositeStopID;
    my $distanceFt;
    
    my $hashRef;
    
    while (<STOPPAIR>)
    {
        my @line = split(/,/);
        
        $routeID        = $line[ $columns->{route_id}         ];
        $stopID         = $line[ $columns->{stop_id}          ];
        $oppositeStopID = $line[ $columns->{opposite_stop_id} ];
        $distanceFt     = trim($line[ $columns->{distance_ft} ]);
        
#        $hashRef = {route_id => $routeID, stop_id => $stopID, opposite_stop_id => $oppositeStopID, distance_ft => $distanceFt};
        $hashRef = {opposite_stop_id => $oppositeStopID, distance_ft => $distanceFt};
        $thisHash{ $routeID }{ $stopID } = $hashRef;
        
    }
    
    close STOPPAIR;
    return \%thisHash;
    
}


sub generateKMLForStopsWithStopHash_X_WithRoutesHash_Y_WithTripsHash_Z_AndShapesHash_A_AndStopTimesHash_B
{
    
    my %stopHash  = %{ $_[0] };
    my %routeHash = %{ $_[1] };
    my %tripsHash = %{ $_[2] };
    my %shapeHash = %{ $_[3] };
    
    my %stopTimesHash = %{ $_[4] };
    
    my $stopPairHashRef = populateStopPairHash( fullPathFor("stopPairs$routeShortName.csv") );
    my %stopPairHash = %{ $stopPairHashRef };
    
    my $tabLevel = 2;
    
    my $header = returnKMLStopHeader();
    $header =~ s/ROUTESHORTNAMEGOESHERE/$routeShortName/;
    $header =~ s/NAMEGOESHERE/$routeShortName/;
    
    p( $header );
    
    # First folder, Shape: ID (X trips), dirY
    
    # NO!  First folder is a complete list of all stops.  End Folder!  Then individual folders per shape.  And stop pairs for those shapes inside that folder.
    my %validStops;
    foreach my $tID ( keys %stopTimesHash )
    {
        foreach my $sID ( @{ $stopTimesHash{$tID} } )
        {
            $validStops{$sID->{stop_id}} = 1;
        }
    }
    
    
    foreach my $key (keys %tripsHash)
    {
        
        my $numOfTrips = $#{ $tripsHash{$key} } +1;
        p($tabLevel, "<Folder>");
        p(++$tabLevel, "<name>Shape: $key ($numOfTrips trips)</name>");
        
        p($tabLevel, "<Placemark>");
        p(++$tabLevel, "<name>Shape: $key ($numOfTrips trips)</name>");
        
        my $tripList;
        foreach my $trips ( @{ $tripsHash{$key} } )
        {
            $tripList .= $trips->{trip_id} . ", ";
        }
        $tripList = substr($tripList, 0, -2);
        
        p($tabLevel,"<description> trip_ids: $tripList</description>");
        p($tabLevel,"<styleUrl>#LineStyle$routeShortName</styleUrl>");
        p($tabLevel,"<LineString>");
        p(++$tabLevel,"<coordinates>");
        
        my $coordString;
        foreach my $hash ( @{ $shapeHash{$key} } )
        {
            $coordString .= "$hash->{shape_pt_lon},$hash->{shape_pt_lat},0 ";
        }
        p($coordString);
        
#        p("  --==  coordinates  ==--");

        p($tabLevel,"</coordinates>");
        p(--$tabLevel,"</LineString>");
        p(--$tabLevel,"</Placemark>");
        
        p($tabLevel,"<Folder>");
        p(++$tabLevel,"<name>Route $routeShortName Stops</name>");

        # To get all the stops for a particular route, grab any trip_id from the %tripsHash, the first will do
        my $tripID = @{ $tripsHash{$key} }[0]->{trip_id};
        my $dirID  = @{ $tripsHash{$key} }[0]->{direction_id};
        
        my $stopName;
        my $stopLat;
        my $stopLon;
        my $stopID;

        
        foreach my $stopInfo ( @{ $stopTimesHash{$tripID} } )
        {
            $stopName = $stopInfo->{stop_name};
            $stopLat  = $stopInfo->{lat};
            $stopLon  = $stopInfo->{lon};
            $stopID   = $stopInfo->{stop_id};

            $validStops{$stopID} = 1;
            
            $stopName =~ s/&/&amp;/;
            
            p($tabLevel++,"<Placemark>");
            p($tabLevel,"<styleUrl>#StopIDs</styleUrl>");
#            p($tabLevel,"<name>$stopID</name>");
            p($tabLevel,"<description>Stop ID: $stopID - $stopName</description>");
            p($tabLevel++,"<Point>");
            p($tabLevel--,"<coordinates>$stopLon,$stopLat</coordinates>");
            p($tabLevel--,"</Point>");
            p($tabLevel,"</Placemark>");

        }  # foreach my $stopInfo ( @{ $stopTimesHash{$tripID} } )
        
        p(--$tabLevel,"</Folder>");

        
        p($tabLevel,"<Folder>");
        p(++$tabLevel,"<name>Stop Pairs</name>");

        # Now build the stop pairs
        
        my $oppositeDirID = (($dirID == 1) ? 0 : 1);
        
#        foreach my $stop ( keys %{ $stopPairHash{ $optRoute_id } } )
        foreach my $stop ( keys %validStops )
        {
            my $opposite = $stopPairHash{$optRoute_id}{$stop}{opposite_stop_id};
            my $stopName = $stopHash{$stop}{stop_name};
            my $oppositeName = $stopHash{$opposite}{stop_name};
            my $distance = $stopPairHash{$optRoute_id}{$stop}{distance_ft};
            
            if ( $distance < 100 )
            {
                next;
            }
            
            $stopName =~ s/&/&amp;/;
            $oppositeName =~ s/&/&amp;/;

            
            p($tabLevel,"<Folder>");
            p(++$tabLevel,"<name>Stop ID $stop -> $opposite, dist: $distance</name>");
            p($tabLevel,"<Placemark>");
            p(++$tabLevel,"<styleUrl>#Direction$dirID</styleUrl>");
            p($tabLevel,"<visibility>0</visibility>");
            p($tabLevel,"<name>$stop</name>");
            p($tabLevel,"<description>$stopName - stop_id: $stop</description>");
            p($tabLevel,"<Point>");
            p(++$tabLevel,"<coordinates>$stopHash{$stop}{stop_lon},$stopHash{$stop}{stop_lat}</coordinates>");
            p(--$tabLevel,"</Point>");
            p(--$tabLevel,"</Placemark>");

            p($tabLevel,"<Placemark>");
            p(++$tabLevel,"<styleUrl>#Direction$oppositeDirID</styleUrl>");
            p($tabLevel,"<visibility>0</visibility>");
            p($tabLevel,"<name>$opposite</name>");
            p($tabLevel,"<description>$oppositeName - stop_id: $opposite</description>");
            p($tabLevel,"<Point>");
            p(++$tabLevel,"<coordinates>$stopHash{$opposite}{stop_lon},$stopHash{$opposite}{stop_lat}</coordinates>");
            p(--$tabLevel,"</Point>");
            p(--$tabLevel,"</Placemark>");
            p(--$tabLevel,"</Folder>");

        }  # foreach my $stop ( keys %{ $stopPairHash{ $optRoute_id } } )
        
        p(--$tabLevel,"</Folder>");
        p(--$tabLevel,"</Folder>");

    }  # foreach my $key (keys %tripsHash)
    
    p(--$tabLevel,"</Document>");
    p(--$tabLevel,"</kml>");
    
    # Placemark with all coordinates
    
    # Folder2
    # All stops
    # End of Folder2
    
    # Folder3, stop pairs
    #  Folder4
    #    Placemark - 1st of the pair
    #    Placemark - 2nd of the pair
    #  End of Folder4
    #  Next Folder for stop pairs
    #  
    
}

#sub changeTabSpacing
#{
#    
#    if ( $_[0] && $_[1] )
#    {
#        int $newSpacing = $_[0];
#        $_[1] = "  "x$newSpacing;
#    }
#    
#}


sub p
{
    
    if ( $_[1] )
    {
        my $tabLevel = shift @_;
        $tabLevel = 0 if ($tabLevel < 0 );
        print "  "x$tabLevel . "@_\n";
    }
    else
    {
        print "@_\n";
    }

}

