// Septa. 2017

import Foundation

typealias AppStackState = [NavigationController: NavigationStackState]

struct NavigationState: Codable {
    let appStackState: AppStackState?
    let selectedTab: Int?

    init(appStackState: AppStackState? = nil, selectedTab: Int? = nil) {
        self.appStackState = appStackState
        self.selectedTab = selectedTab
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    switch (lhs.appStackState, rhs.appStackState) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.appStackState! == rhs.appStackState!
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
