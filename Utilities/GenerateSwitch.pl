use Modern::Perl;
use Data::Dumper; 

my $defaultReturn = q| return "schedules"   |;

my $enumInstanceName = q|  self |;

my $enum = q |

enum ViewController: String, Equatable {
    /// Initial screen in schedules.  Holds the toolbar. Root view controller
    case selectSchedules
    case routesViewController
    case selectStartController
    case selectStopController
    case selectStopNavigationController
    case tripScheduleController
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

