// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleData : Codable {
    let availableRoutes: [Route]?
    let availableStarts: [Stop]?
    let availableStops: [Stop]?
    let availableTrips: [Trip]?

    init(availableRoutes: [Route]? = nil, availableStarts: [Stop]? = nil, availableStops: [Stop]? = nil, availableTrips: [Trip]? = nil) {
        self.availableRoutes = availableRoutes
        self.availableStarts = availableStarts
        self.availableStops = availableStops
        self.availableTrips = availableTrips
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

    switch (lhs.availableStarts, rhs.availableStarts) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableStarts! == rhs.availableStarts!
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

    switch (lhs.availableTrips, rhs.availableTrips) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.availableTrips! == rhs.availableTrips!
    default:
        return false
    }
    return areEqual
}
