// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol NextToArriveMiddlewareAction: SeptaAction {}

struct NavigateToNextToArriveFromSchedules: NextToArriveMiddlewareAction {

    let description = "Navigate to Next To Arrive From Schedules"
}

struct NavigateToSchedulesFromNextToArrive: NextToArriveMiddlewareAction {
    let nextToArriveTrip: NextToArriveTrip
    let description = "Navigate to SchedulesFromNextToArrive"
}
