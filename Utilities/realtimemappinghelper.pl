use Modern::Perl;

  my @vars = ();

  my $orig = q|
  public var orig_arrival_time: String?
  public var orig_delay_minutes: Int?
  public var orig_departure_time: String?
  public var orig_last_stop_id: String?
  public var orig_last_stop_name: String?
  public var orig_line_direction: String?
  public var orig_line_route_id: String?
  public var orig_line_route_name: String?
  public var orig_line_trip_id: String?

  |;

  while ($orig =~ m/(?<=var )(\w+)/smg) {
	push @vars, $1;
}

my $template = q|
	if  a.%var% == nil {
        print ("%var% could not be found")
    }
|;

for (@vars){
	my $guard = $template;
	$guard =~ s/%var%/$_/g;
	say $guard;
}
