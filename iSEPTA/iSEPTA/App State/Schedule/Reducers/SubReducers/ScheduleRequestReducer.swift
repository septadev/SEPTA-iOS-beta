// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

struct ScheduleRequestReducer {

    static func initRequest() -> ScheduleRequest {
        let transitMode = stateProviders.preferenceProvider.retrievePersistedState().transitMode
        return ScheduleRequest(transitMode: transitMode)
    }

    static func reduceRequest(action: ScheduleAction, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        var newScheduleRequest: ScheduleRequest
        switch action {
        case let action as TransitModeSelected:
            newScheduleRequest = ScheduleRequest(transitMode: action.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil, onlyOneRouteAvailable: false)
        case let action as RouteSelected:
            newScheduleRequest = reduceRouteSelected(action: action, scheduleRequest: scheduleRequest)
        default:
            newScheduleRequest = scheduleRequest
        }
        return newScheduleRequest
    }

    static func reduceRouteSelected(action: RouteSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: action.route)
    }
}
