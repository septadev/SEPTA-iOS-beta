// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

struct ScheduleRequestReducer {

    static func initRequest() -> ScheduleRequest {
        return ScheduleRequest()
    }

    static func reduceRequest(action: ScheduleAction, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        var newScheduleRequest: ScheduleRequest
        switch action {
        case let action as TransitModeSelected:
            newScheduleRequest = reduceTransitModeSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as RouteSelected:
            newScheduleRequest = reduceRouteSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as TripStartSelected:
            newScheduleRequest = reduceTripStartSelected(action: action, scheduleRequest: scheduleRequest)
        default:
            newScheduleRequest = scheduleRequest
        }
        return newScheduleRequest
    }

    static func reduceTransitModeSelected(action: TransitModeSelected, scheduleRequest _: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: action.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil, onlyOneRouteAvailable: false)
    }

    static func reduceRouteSelected(action: RouteSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: action.selectedRoute)
    }

    static func reduceTripStartSelected(action _: TripStartSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute)
    }
}
