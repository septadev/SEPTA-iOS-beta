// Septa. 2017

import Foundation

struct NavigationState: Codable {
    let navigationControllers: [NavigationController]?
    let selectedTab: NavigationController?

    init(navigationControllers: [NavigationController]? = nil, selectedTab: NavigationController? = nil) {
        self.navigationControllers = navigationControllers
        self.selectedTab = selectedTab
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    switch (lhs.navigationControllers, rhs.navigationControllers) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.navigationControllers! == rhs.navigationControllers!
    default:
        return false
    }

    switch (lhs.selectedTab, rhs.selectedTab) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedTab! == rhs.selectedTab!
    default:
        return false
    }
    return areEqual
}
