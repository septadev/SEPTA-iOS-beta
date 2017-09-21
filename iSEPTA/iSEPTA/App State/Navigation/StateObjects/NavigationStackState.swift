// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

struct NavigationStackState {
    let viewControllers: [ViewController]
    let modalViewController: ViewController?

    init(viewControllers: [ViewController] = [ViewController](), modalViewController: ViewController? = nil) {
        self.viewControllers = viewControllers
        self.modalViewController = modalViewController
    }
}

extension NavigationStackState: Equatable {}
func ==(lhs: NavigationStackState, rhs: NavigationStackState) -> Bool {
    var areEqual = true

    areEqual = lhs.viewControllers == rhs.viewControllers
    guard areEqual else { return false }

    switch (lhs.modalViewController, rhs.modalViewController) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.modalViewController! == rhs.modalViewController!
    default:
        return false
    }
    guard areEqual else { return false }

    return areEqual
}
