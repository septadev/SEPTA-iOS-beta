use Modern::Perl;
use Data::Dumper; 

my $defaultReturn = q| return "transitType"   |;

my $enumInstanceName = q|  transitMode |;

my $enum = q |

@objc public enum TransitMode: Int, Codable {
    case bus
    case rail
    case subway
    case nhsl
    case trolley
}



	|;

my $switchTemplate =  q|
	switch %instanceName% {
%cases%
	}
|;


my @cases = ();
while ($enum =~ m/(?:case)\s+(\w+)/mg) {
	push @cases, "        case .$1: \n            $defaultReturn";
}
my $caseString = join "\n", @cases; 

$switchTemplate=~ s/%cases%/$caseString/;
$switchTemplate=~ s/%instanceName%/$enumInstanceName/;

say $switchTemplate;

