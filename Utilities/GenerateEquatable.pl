use Modern::Perl;
use Data::Dumper; 

my $struct = q |

struct ScheduleData {
    let availableRoutes: ScheduleRouteState

    let availableStarts: ScheduleStopState
    let availableStops: ScheduleStopState
    let availableTrips: ScheduleTripState


    init(availableRoutes: [Route]? = nil, availableStarts: [Stop]? = nil, availableStops: [Stop]? = nil, availableTrips: [Trip]? = nil, errorString: String? = nil) {
        self.availableRoutes = availableRoutes
        self.availableStarts = availableStarts
        self.availableStops = availableStops
        self.availableTrips = availableTrips
        self.errorString = errorString
    }
}
	|;

my @initVars = ();
my @vars = ();
while ($struct =~ m/(?:let|var)\s+(\w+)\s*:\s*([\w:\[\]\h]+)(\?*)\h*$/mg) {
	my $switchTemplate;
	if ($3) {
	$switchTemplate = qq |
	areEqual = Optionals.optionalCompare(currentValue: lhs.$1, newValue: rhs.$1).equalityResult()
	guard areEqual else { return false }

	|;
	} else {
		$switchTemplate = qq |
		areEqual = lhs.$1 == rhs.$1
		guard areEqual else { return false }
|;
	}
	
	push @initVars, ["$1","$2$3"];
	push @vars, $switchTemplate;
}

my $varString = join "\n", @vars;

my $structName;
$struct =~ m/struct (\w+)/m; 
$structName = $1;

my $output = qq |
 extension $structName: Equatable {}
 func ==(lhs: $structName, rhs: $structName) -> Bool {
	var areEqual = true
	
	$varString
	return areEqual
	}
|;

say  $output;

my $initparams = join ', ', map {"$_->[0]: $_->[1]"} @initVars;
$initparams =~ s/(.\?)/$1 = nil/mg;
my $initdeclares = join "\n", map {"self.$_->[0] = $_->[0]"} @initVars;


say qq |
	 init($initparams){
	$initdeclares
}|;

