// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleData {
    let availableRoutes: ScheduleRouteState

    let availableStarts: ScheduleStopState
    let availableStops: ScheduleStopState
    let availableTrips: ScheduleTripState

    init(availableRoutes: ScheduleRouteState = ScheduleRouteState(),
         availableStarts: ScheduleStopState = ScheduleStopState(),
         availableStops: ScheduleStopState = ScheduleStopState(),
         availableTrips: ScheduleTripState = ScheduleTripState()) {
        self.availableRoutes = availableRoutes
        self.availableStarts = availableStarts
        self.availableStops = availableStops
        self.availableTrips = availableTrips
    }
}

extension ScheduleData: Equatable {}
func ==(lhs: ScheduleData, rhs: ScheduleData) -> Bool {
    var areEqual = true

    areEqual = lhs.availableRoutes == rhs.availableRoutes
    guard areEqual else { return false }

    areEqual = lhs.availableStarts == rhs.availableStarts
    guard areEqual else { return false }

    areEqual = lhs.availableStops == rhs.availableStops
    guard areEqual else { return false }

    areEqual = lhs.availableTrips == rhs.availableTrips
    guard areEqual else { return false }

    return areEqual
}
