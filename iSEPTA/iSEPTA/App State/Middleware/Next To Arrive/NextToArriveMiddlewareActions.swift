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

struct NavigateToSchedulesFromNextToArriveScheduleRequest: NextToArriveMiddlewareAction {
    let scheduleRequest: ScheduleRequest
    let description = "Navigate to SchedulesFromNextToArrive schedule request"
}

struct NavigateToAlertDetailsFromSchedules: NextToArriveMiddlewareAction {
    let scheduleState: ScheduleState
    let description = "Navigate to Alert Details From Schedules"
}

struct NavigateToAlertDetailsFromNextToArrive: NextToArriveMiddlewareAction {
    let scheduleRequest: ScheduleRequest
    let nextToArriveStop: NextToArriveStop
    let description = "Navigate to Alert Details From Next To Arrive"
}
