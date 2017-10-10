use Modern::Perl;
use JSON;
use Data::Dumper;
use Scalar::Util qw/reftype  looks_like_number /;

my $className = "NextToArriveDetails";

my $raw = q|
{
    "tripid": "774",
    "destination": "Chestnut H East",
    "details": {
        "tripid": "774",
        "latitude": 40.002131166667,
        "longitude": -75.1420705,
        "line": "Trenton",
        "track": "",
        "trackChange": "",
        "speed": "56.3 MPH",
        "direction": "North",
        "service": "LOCAL",
        "source": "Trenton",
        "nextstop": {
            "station": "North Philadelphia",
            "delay": 5
        },
        "destination": {
            "station": "Chestnut H East",
            "delay": 5
        },
        "consist": ["165", "166"]
    },
    "results": 1
}

|;

my $hash       = decode_json($raw);
my @properties = ();
buildHash( $hash, [] );

buildClass();
buildMap();


sub buildHash {
    my $hash    = shift @_;
    my $keyPath = shift @_;
    for my $key ( keys %{$hash} ) {
        my $value     = $hash->{$key};
        my @myKeyPath = @$keyPath;
        push @myKeyPath, $key;
        my $type;

        if ( ref $value && reftype $value eq reftype {} ) {
            buildHash( $value, \@myKeyPath );
            $type = "Hash";
        }
        elsif ( ref $value && reftype $value eq reftype [] ) {
            $type = "Array";
        }
        elsif ( looks_like_number $value && int($value) == $value && !JSON::is_bool($value) ) {
            $type = "Int";
        }
        elsif ( looks_like_number $value && int($value) != $value ) {
            $type = "Double";
        }
        elsif ( JSON::is_bool $value) {
            $type = "Bool";
        }
        elsif ( $value =~ m/000Z/ ) {
            $type = "Date";
        }
        else {
            $type = "String";
        }
        my $entry = { type => $type, value => $value,, keyPath => \@myKeyPath };

        push @properties, $entry;

    }
}

sub buildClass {
    say "class $className {";
    my @sortedProperties = sort { $a->{keyPath}->[-1] cmp $b->{keyPath}->[-1] } @properties;
	

    for (@sortedProperties) {
        my $type : = $_->{type};
        my @matchingTypes = qw|String  Date  Double   Int Array |;
        if ( grep { $type eq $_ } @matchingTypes ) {
        	my @flatKeyPath = grep {$_ ne 'details'} @{$_->{keyPath}};
            my $lastKey = $flatKeyPath[-1];
            my $penKey  = $flatKeyPath[-2];

            if ($penKey ) {
				$lastKey = ucfirst $lastKey;
            } else {
            	$penKey = "";
            }

            say "public var $penKey$lastKey: $type?";
            $_->{varName} = "$penKey$lastKey";
        }
    }
    say "}";
}

sub buildMap{
	say 'public func mapping(map: Map) {';

        # orig_line_route_id <- map["orig_line_route_id"]
        for (@properties){
        	my $keyPath = join ".", @{$_->{keyPath}};
			say qq|$_->{varName} <- map["$keyPath"]|;

        }
   say ' } ';


}
