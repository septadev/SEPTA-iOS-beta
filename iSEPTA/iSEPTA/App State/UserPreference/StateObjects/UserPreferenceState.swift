// Septa. 2017

import Foundation
import SeptaSchedule

struct UserPreferenceState: Codable {
    var startupTransitMode: TransitMode?
    var startupNavigationController: NavigationController?
    var showDirectionInRoutes: Bool?
    var showDirectionInStops: Bool?
}

extension UserPreferenceState: Equatable {}
func ==(lhs: UserPreferenceState, rhs: UserPreferenceState) -> Bool {
    var areEqual = true

    switch (lhs.startupTransitMode, rhs.startupTransitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.startupTransitMode! == rhs.startupTransitMode!
    default:
        return false
    }

    guard areEqual else { return false }

    switch (lhs.startupNavigationController, rhs.startupNavigationController) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.startupNavigationController! == rhs.startupNavigationController!
    default:
        return false
    }

    guard areEqual else { return false }

    switch (lhs.showDirectionInRoutes, rhs.showDirectionInRoutes) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.showDirectionInRoutes! == rhs.showDirectionInRoutes!
    default:
        return false
    }

    guard areEqual else { return false }

    switch (lhs.showDirectionInStops, rhs.showDirectionInStops) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.showDirectionInStops! == rhs.showDirectionInStops!
    default:
        return false
    }
    return areEqual
}
