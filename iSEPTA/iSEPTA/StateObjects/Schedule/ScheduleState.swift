// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {
    let transitMode: TransitMode
    let routes: [Route]?
    let selectedRoute: Route?
    let availableStarts: [Stop]?
    let selectedStart: Stop?
    let availableStops: [Stop]?
    let selectedStop: Stop?
    let availableTrips: [Trip]?
    let featureViewControllerDisplayState: FeatureViewControllerDisplayState?

    public init(transitMode: TransitMode, routes: [Route]?, selectedRoute: Route?, availableStarts: [Stop]?, selectedStart: Stop?, availableStops: [Stop]?, selectedStop: Stop?, availableTrips: [Trip]?, featureViewControllerDisplayState: FeatureViewControllerDisplayState?) {
        self.transitMode = transitMode
        self.routes = routes
        self.selectedRoute = selectedRoute
        self.availableStarts = availableStarts
        self.selectedStart = selectedStart
        self.availableStops = availableStops
        self.selectedStop = selectedStop
        self.availableTrips = availableTrips
        self.featureViewControllerDisplayState = featureViewControllerDisplayState
    }
}

extension ScheduleState: Equatable {}
func ==(lhs: ScheduleState, rhs: ScheduleState) -> Bool {
    var areEqual = true

    if lhs.transitMode == rhs.transitMode {
        areEqual = true
    } else {
        return false
    }

    switch (lhs.routes, rhs.routes) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.routes! == rhs.routes!
    default:
        return false
    }

    switch (lhs.selectedRoute, rhs.selectedRoute) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedRoute! == rhs.selectedRoute!
    default:
        return false
    }

    switch (lhs.availableStarts, rhs.availableStarts) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableStarts! == rhs.availableStarts!
    default:
        return false
    }

    switch (lhs.selectedStart, rhs.selectedStart) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedStart! == rhs.selectedStart!
    default:
        return false
    }

    switch (lhs.availableStops, rhs.availableStops) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableStops! == rhs.availableStops!
    default:
        return false
    }

    switch (lhs.selectedStop, rhs.selectedStop) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedStop! == rhs.selectedStop!
    default:
        return false
    }

    switch (lhs.availableTrips, rhs.availableTrips) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableTrips! == rhs.availableTrips!
    default:
        return false
    }

    switch (lhs.featureViewControllerDisplayState, rhs.featureViewControllerDisplayState) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.featureViewControllerDisplayState! == rhs.featureViewControllerDisplayState!
    default:
        return false
    }
    return areEqual
}
