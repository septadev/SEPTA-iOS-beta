use Modern::Perl;
use Data::Dumper; 
my $struct = q |

struct Schedule {
	let route: Int
	let name: String
	let start: String?


}




|;



my @vars = ();



while ($struct =~ m/(let|var)\s+(\w+)\s*:\s*(\w+)(\??)/mg) {
	push @vars, "lhs.$2 == rhs.$2";
}

my $varString = join " && \n", @vars;

my $structName;
$struct =~ m/struct (\w+)/m; 
$structName = $1;

my $output = qq |
extension $structName: Equatable {}
func ==(lhs: $structName, rhs: $structName) -> Bool {
	return $varString
}

|;

say  $output;
