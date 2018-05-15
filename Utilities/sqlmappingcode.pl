#!/usr/bin/perl
use Modern::Perl;
my $struct = q |
public struct Stop: Codable {
		public let stopId: Int
		public let stopName: String
		public let stopLatitude: Double
		public let stopLongitude: Double
		public let wheelchairBoarding: Bool
		public let weekdayService: Bool
		public let saturdayService: Bool
		public let sundayService: Bool

		init(stopId: Int, stopName: String, stopLatitude: Double, stopLongitude: Double, wheelchairBoarding: Bool) {
			self.stopId = stopId
			self.stopName = stopName
			self.stopLatitude = stopLatitude
			self.stopLongitude = stopLongitude
			self.wheelchairBoarding = wheelchairBoarding
		}
	}
	
	|;
	my $counter = 0;
	my @result = ();
	my @propNames = ();
	my($structName) = "$struct" =~ /(?<=struct )(\w+)/;
	while ($struct =~ m/(?:let|var)\s+(\w+)\s*:\s*([\w:\[\]\h]+)(\?*)\h*$/mg) {
		push @result, "let col$counter = row[$counter], let $1 = col$counter as? $2";
		push @propNames, $1;
		$counter++;
	}
	
	my $string = join ",\n", @result;
	say "$string\{";
	say "";
	
	my @initParams = map { "$_:$_" } @propNames;
	my $initString = join ", ", @initParams;
	say "$structName\($initString\)";

