use Modern::Perl;
use JSON;
use File::Slurp;
use Data::Dumper;

my $dbBusText = read_file('dbBus.json');
my $dbBus     = decode_json($dbBusText);

my $dbRailText = read_file('dbRail.json');
my $dbRail     = decode_json($dbRailText);

my $webAlertsText = read_file('webalerts.json');
my $webAlerts     = decode_json($webAlertsText);
$webAlerts = $webAlerts->{alerts};

my $mapperText = read_file('webAlertsToAppStateMap.json');
my $mapper     = decode_json($mapperText);
$mapper = $mapper->{mode};

my $newMapperText = read_file('WebAlertsRoutesMappedToDBRoutes.json');
my $newMapper     = decode_json($newMapperText);


my $webAlertModes = {};

my $transitModeMapper = {};
for ((0..4)){
	my $transitMode = $_;
	my $transitModeHash = {};

	for (keys %$newMapper){
		my $modeKey = $_;
		my $modeValue = $newMapper->{$modeKey};
		for (keys %$modeValue){
			my $routeKey = $_;
			my $routeValue = $modeValue->{$routeKey};
			my $dbRouteId = $routeValue->{dbRouteId};
			my $transitModes = $routeValue->{transitModes};
			
			if (grep {$_ == $transitMode} @$transitModes ) {
				$transitModeHash->{$dbRouteId} = $routeKey;

			}
		}
	}

	 $transitModeMapper->{$transitMode} = $transitModeHash;
}

say Dumper $transitModeMapper;
my $transitModeMapperJson = encode_json $transitModeMapper;
write_file "DbAlertsMappedToWebAlerts.json", $transitModeMapperJson;

sub buildNewMapper {

    my $newMapper = {};
    my $newMapperMode = $newMapper->{mode} = {};

    for ( keys %$mapper ) {
        my $key                = $_;
        my $mode               = $mapper->{$key};
        my $newTransitHash     = $newMapperMode->{$key} = {};
        my $defaultTransitMode = $mode->{transitMode};
        my $maps               = $mode->{mapFromAlertRouteToDbRoute};
        for ( keys %$maps ) {
            my $routeKey  = $_;
            my $dbRouteId = $maps->{$routeKey};
            $newTransitHash->{$routeKey} = { transitModes => [$defaultTransitMode], dbRouteId => $dbRouteId };
        }
    }
    my $newMapperJson = encode_json $newMapper;
    write_file "WebAlertsRoutesMappedToDBRoutes.json", $newMapperJson;
}

sub buildWebAlertModes {
    for (@$webAlerts) {
        $webAlertModes->{ $_->{mode} } = 1;
    }
}

sub reverseKeys {
    for ( keys %$mapper ) {
        my $mode = $_;

        my $mapFromDbRouteToAlertRoute = {};
        my $alertToDbMap               = $mapper->{$mode}->{mapFromAlertRouteToDbRoute};

        for ( keys %$alertToDbMap ) {
            my $alertRoute = $_;
            my $dbroute    = $alertToDbMap->{$alertRoute};
            $mapFromDbRouteToAlertRoute->{$dbroute} = $alertRoute;
        }
        $mapper->{$mode}->{mapFromDbRouteToAlertRoute} = $mapFromDbRouteToAlertRoute;
    }
}

sub findMissingMapKeysForAllModes {
    for ( keys %$webAlertModes ) {
        findMissingMapKeysForMode($_);
    }
}

sub findMissingMapKeysForMode {
    my $key    = shift;
    my $mapper = $mapper->{$key}->{mapFromAlertRouteToDbRoute};
    my @alerts = grep { $_->{mode} eq $key } @$webAlerts;
    for (@alerts) {
        my $alertRouteId = $_->{route_id};
        my $appRouteId   = $mapper->{$alertRouteId};
        say "Missing $key for: $alertRouteId" unless defined $appRouteId;
    }

}

sub mapBusRoutes {
    my $mode                          = shift;
    my $mapBusFromAlertRouteToDbRoute = {};
    my @busAlerts                     = grep { $_->{mode} eq $mode } @$webAlerts;

    for (@busAlerts) {
        my $route_id   = $_->{route_id};
        my $route_name = $_->{route_name};
        $mapBusFromAlertRouteToDbRoute->{ $_->{route_id} } = $_->{route_name};
    }

    my $mapBusString = encode_json $mapBusFromAlertRouteToDbRoute;
    say $mapBusString;
}

