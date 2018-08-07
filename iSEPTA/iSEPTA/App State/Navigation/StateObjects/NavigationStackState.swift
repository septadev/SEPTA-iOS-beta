// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

struct NavigationStackState: Equatable {
    var dismissModal: DismissModal?
    var presentModal: PresentModal?
    var pushViewController: PushViewController?
    var popViewController: PopViewController?
}
