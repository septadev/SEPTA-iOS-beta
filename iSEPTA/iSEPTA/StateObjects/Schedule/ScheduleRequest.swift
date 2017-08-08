// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest {
    let selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let transitMode: TransitMode?
    let onlyOneRouteAvailable: Bool

    init(selectedRoute: Route? = nil, selectedStart: Stop? = nil, selectedEnd: Stop? = nil, transitMode: TransitMode? = nil, onlyOneRouteAvailable: Bool = false) {
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.transitMode = transitMode
        self.onlyOneRouteAvailable = onlyOneRouteAvailable
    }
}

extension ScheduleRequest: Equatable {}
func ==(lhs: ScheduleRequest, rhs: ScheduleRequest) -> Bool {
    var areEqual = true

    switch (lhs.selectedRoute, rhs.selectedRoute) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedRoute! == rhs.selectedRoute!
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

    switch (lhs.selectedEnd, rhs.selectedEnd) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedEnd! == rhs.selectedEnd!
    default:
        return false
    }

    switch (lhs.transitMode, rhs.transitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.transitMode! == rhs.transitMode!
    default:
        return false
    }

    if lhs.onlyOneRouteAvailable == rhs.onlyOneRouteAvailable {
        areEqual = true
    } else {
        return false
    }
    return areEqual
}
