
// Septa. 2017

import Foundation
import ReSwift
import SeptaRest
import SeptaSchedule

protocol NextToArriveAction: SeptaAction {}

struct NextToArrivePrerequisteStatusChanged: NextToArriveAction {
    let newStatus: NextToArrivePrerequisiteStatus
    let description = "The underlying dependencies for the NTA service call have changed"
}

struct NextToArriveRefreshDataRequested: NextToArriveAction {
    let refreshUpdateRequested: Bool
    let description = "User has a requested a refresh of Next to arrive data"
}

struct ClearNextToArriveData: NextToArriveAction {
    let description = "All next to arrive data should be cleared"
}

struct UpdateNextToArriveStatusAndData: NextToArriveAction {
    let nextToArriveUpdateStatus: NextToArriveUpdateStatus
    let nextToArriveTrips: [NextToArriveTrip]
    let refreshDataRequested: Bool
    let description = "Provider reporting on the status of the update"
}

struct UpdateNextToArriveDetail: NextToArriveAction {
    let realTimeArrivalDetail: RealTimeArrivalDetail
    let description: String
}

struct ViewScheduleDataInNextToArrive: NextToArriveAction {
    let description = "Jumping from schedules to next to arrive"
}

struct InsertNextToArriveScheduleRequest: NextToArriveAction {
    let scheduleRequest: ScheduleRequest
    let description = "force a new schedule request into NTA"
}

struct ToggleNextToArriveReverseTripStatus: NextToArriveAction {
    let description = "Dispatch this action to change the status for trip reversal for next to arrive."
}

struct RemoveNextToArriveReverseTripStatus: NextToArriveAction {
    let description = "Next To Arrive Status should be in the .noReverse state"
}
