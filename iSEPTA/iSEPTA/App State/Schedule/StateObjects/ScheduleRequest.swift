// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest {
    let databaseIsLoaded: Bool
    let transitMode: TransitMode?
    let selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let stopToEdit: StopToSelect?
    let scheduleType: ScheduleType?
    let reverseStops: Bool

    init(transitMode: TransitMode? = nil, selectedRoute: Route? = nil, selectedStart: Stop? = nil, selectedEnd: Stop? = nil, stopToEdit: StopToSelect? = nil, scheduleType: ScheduleType? = .weekday, reverseStops: Bool = false, reloadDatabase _: Bool = false, databaseIsLoaded: Bool = false) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.stopToEdit = stopToEdit
        self.scheduleType = scheduleType
        self.reverseStops = reverseStops
        self.databaseIsLoaded = databaseIsLoaded
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
        return false
    }
    guard areEqual else { return false }

    switch (lhs.selectedRoute, rhs.selectedRoute) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedRoute! == rhs.selectedRoute!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.selectedStart, rhs.selectedStart) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedStart! == rhs.selectedStart!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.selectedEnd, rhs.selectedEnd) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedEnd! == rhs.selectedEnd!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.stopToEdit, rhs.stopToEdit) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.stopToEdit! == rhs.stopToEdit!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.scheduleType, rhs.scheduleType) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.scheduleType! == rhs.scheduleType!
    default:
        return false
    }
    guard areEqual else { return false }

    if lhs.reverseStops == rhs.reverseStops {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.databaseIsLoaded == rhs.databaseIsLoaded {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    return areEqual
}
