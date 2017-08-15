// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest {
    let transitMode: TransitMode?
    let selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let stopToEdit: StopToSelect?

    init(transitMode: TransitMode? = nil, selectedRoute: Route? = nil, selectedStart: Stop? = nil,
         selectedEnd: Stop? = nil, stopToEdit: StopToSelect? = nil) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.stopToEdit = stopToEdit
    }
}

extension ScheduleRequest: Equatable {}
func ==(lhs: ScheduleRequest, rhs: ScheduleRequest) -> Bool {
    var areEqual = true

    switch (lhs.transitMode, rhs.transitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.transitMode! == rhs.transitMode!
    default:
        areEqual = false
    }
    guard areEqual else { return false }

    switch (lhs.selectedRoute, rhs.selectedRoute) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedRoute! == rhs.selectedRoute!
    default:
        areEqual = false
    }
    guard areEqual else { return false }

    switch (lhs.selectedStart, rhs.selectedStart) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedStart! == rhs.selectedStart!
    default:
        areEqual = false
    }
    guard areEqual else { return false }

    switch (lhs.selectedEnd, rhs.selectedEnd) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedEnd! == rhs.selectedEnd!
    default:
        areEqual = false
    }
    guard areEqual else { return false }

    switch (lhs.stopToEdit, rhs.stopToEdit) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.stopToEdit! == rhs.stopToEdit!
    default:
        areEqual = false
    }
    guard areEqual else { return false }

    guard areEqual else { return false }
    print("Schedule Requests are equal")
    return areEqual
}
