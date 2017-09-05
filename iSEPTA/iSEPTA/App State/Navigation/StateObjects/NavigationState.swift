// Septa. 2017

import Foundation
import SeptaSchedule

typealias AppStackState = [NavigationController: NavigationStackState]

struct NavigationState {
    let appStackState: AppStackState
    let activeNavigationController: NavigationController

    init(appStackState: AppStackState = [NavigationController: NavigationStackState](), activeNavigationController: NavigationController = .nextToArrive) {
        self.appStackState = appStackState
        self.activeNavigationController = activeNavigationController
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    areEqual = lhs.appStackState == rhs.appStackState
    guard areEqual else { return false }

    areEqual = lhs.activeNavigationController == rhs.activeNavigationController
    guard areEqual else { return false }

    return areEqual
}
