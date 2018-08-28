// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleData: Equatable {
    var availableRoutes: ScheduleRouteState = ScheduleRouteState()

    var availableStarts: ScheduleStopState = ScheduleStopState()
    var availableStops: ScheduleStopState = ScheduleStopState()
    var availableTrips: ScheduleTripState = ScheduleTripState()
}
