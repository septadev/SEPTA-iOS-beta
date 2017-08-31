// Septa. 2017

import Foundation
import SeptaSchedule

typealias AppStackState = [NavigationController: NavigationStackState]

struct NavigationState {
    let appStackState: AppStackState
    let selectedTab: NavigationController

    init(appStackState: AppStackState = [NavigationController: NavigationStackState](), selectedTab: NavigationController = .nextToArrive) {
        self.appStackState = appStackState
        self.selectedTab = selectedTab
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    areEqual = lhs.appStackState == rhs.appStackState
    guard areEqual else { return false }

    areEqual = lhs.selectedTab == rhs.selectedTab
    guard areEqual else { return false }

    return areEqual
}
