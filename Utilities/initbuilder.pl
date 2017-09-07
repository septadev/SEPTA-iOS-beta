 
use Modern::Perl;




    my @vars = ();

  my $orig = q|
     let routeId: String?
    let routeName: String?
    let tripId: Int?

    let arrivalTime: Date
    let departureTime: Date
    let lastStopId: Int?
    let lastStopName: String?
    let delayMinutes: Int?
    let direction: RouteDirectionCode?

  |;

  while ($orig =~ m/(?<=let )(\w+)/smg) {
	push @vars, "$1: $1";
}

my $line = join ", " , @vars;

say $line;