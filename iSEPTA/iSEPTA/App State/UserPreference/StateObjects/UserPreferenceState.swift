// Septa. 2017

import Foundation
import SeptaSchedule

struct UserPreferenceState: Codable {
    var transitMode: TransitMode?
    var defaultNavigationController: NavigationController?
    var defaultTransitMode: TransitMode?
    var showDirectionInRoutes: Bool?
    var showDirectioninStops: Bool?
}

extension UserPreferenceState: Equatable {}
func ==(lhs: UserPreferenceState, rhs: UserPreferenceState) -> Bool {
    var areEqual = true

    switch (lhs.transitMode, rhs.transitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.transitMode! == rhs.transitMode!
    default:
        return false
    }

    switch (lhs.defaultNavigationController, rhs.defaultNavigationController) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.defaultNavigationController! == rhs.defaultNavigationController!
    default:
        return false
    }

    switch (lhs.defaultTransitMode, rhs.defaultTransitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.defaultTransitMode! == rhs.defaultTransitMode!
    default:
        return false
    }

    switch (lhs.showDirectionInRoutes, rhs.showDirectionInRoutes) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.showDirectionInRoutes! == rhs.showDirectionInRoutes!
    default:
        return false
    }

    switch (lhs.showDirectioninStops, rhs.showDirectioninStops) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.showDirectioninStops! == rhs.showDirectioninStops!
    default:
        return false
    }
    return areEqual
}
