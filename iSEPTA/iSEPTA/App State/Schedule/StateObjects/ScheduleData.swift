// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleData {
    let availableRoutes: [Route]?

    let availableStarts: [Stop]?
    let availableStops: [Stop]?
    let availableTrips: [Trip]?
    let errorString: String?

    init(availableRoutes: [Route]? = nil, availableStarts: [Stop]? = nil, availableStops: [Stop]? = nil, availableTrips: [Trip]? = nil, errorString: String? = nil) {
        if availableRoutes == nil {
            let i = 0
        }
        self.availableRoutes = availableRoutes
        self.availableStarts = availableStarts
        self.availableStops = availableStops
        self.availableTrips = availableTrips
        self.errorString = errorString
    }
}

extension ScheduleData: Equatable {}
func ==(lhs: ScheduleData, rhs: ScheduleData) -> Bool {
    var areEqual = true

    switch (lhs.availableRoutes, rhs.availableRoutes) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableRoutes! == rhs.availableRoutes!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.availableStarts, rhs.availableStarts) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableStarts! == rhs.availableStarts!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.availableStops, rhs.availableStops) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableStops! == rhs.availableStops!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.availableTrips, rhs.availableTrips) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableTrips! == rhs.availableTrips!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.errorString, rhs.errorString) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.errorString! == rhs.errorString!
    default:
        return false
    }
    guard areEqual else { return false }

    return areEqual
}
