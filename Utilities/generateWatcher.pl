use Modern::Perl;

use String::Util  ':all';
use Modern::Perl;
use Data::Dumper; 

my $type = q| NextToArriveReverseTripStatus   |;

my $keyPath = q|  favoriteState.nextToArriveReverseTripStatus |;



my $template = q |
// Septa. 2018

import SeptaSchedule
import ReSwift

protocol %DelegateName%: AnyObject {
	func %UpdateMethod%Updated(%TypeParam%: %Type%) 
}

class %ClassName%: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = %Type%

    weak var %DelegateInstance%: %DelegateName%? {
        didSet {
            subscribe()
        }
    }

   

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.%KeyPath% }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        %DelegateInstance%?.%UpdateMethod%Updated(%TypeParam%: state )
    }
}



|;

my $flattenedKeyPath= trim($keyPath);
$flattenedKeyPath =~ s/(^|\.)(\w+)/_\u$2/smg;
$flattenedKeyPath =~ s/^_//smg;
my $className = "${flattenedKeyPath}Watcher";

my $delegateName = $className;
$delegateName .= "Delegate";

my $output = $template;
$type = trim($type);
my $typeParam = "\l$type";
$typeParam =~ s/\?//g;
$keyPath = trim($keyPath);

my $delegateInstance = "delegate";
my $updateMethodName = $className;
$output =~ s/%Type%/$type/g;
$output =~ s/%DelegateName%/$delegateName/g;
$output =~ s/%ClassName%/$className/g;
$output =~ s/%TypeParam%/$typeParam/g;
$output =~ s/%KeyPath% /$keyPath/g;
$output =~ s/%DelegateInstance%/$delegateInstance/g;
$output =~ s/%UpdateMethod%/\l$flattenedKeyPath/g;
print $output;
