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
            newScheduleRequest = reduceTransitModeSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as RouteSelected:
            newScheduleRequest = reduceRouteSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as RoutesLoaded:
            newScheduleRequest = reduceRoutesLoaded(action: action, scheduleRequest: scheduleRequest)
        default:
            newScheduleRequest = scheduleRequest
        }
        return newScheduleRequest
    }

    static func reduceTransitModeSelected(action: TransitModeSelected, scheduleRequest _: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: action.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil, onlyOneRouteAvailable: false)
    }

    static func reduceRouteSelected(action: RouteSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: action.route)
    }

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        guard let routes = action.routes else { return scheduleRequest }
        let origSR = scheduleRequest
        if routes.count == 1 {

            return ScheduleRequest(transitMode: origSR.transitMode, selectedRoute: routes[0], selectedStart: origSR.selectedStart, selectedEnd: origSR.selectedEnd, onlyOneRouteAvailable: true)
        } else {
            return origSR
        }
    }
}
