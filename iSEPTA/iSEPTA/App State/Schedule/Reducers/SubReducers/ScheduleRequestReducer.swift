// Septa. 2017

import Foundation
import ReSwift

struct ScheduleRequestReducer {

    static func initRequest() -> ScheduleRequest {
        let transitMode = stateProviders.preferenceProvider.retrievePersistedState().transitMode
        return ScheduleRequest(transitMode: transitMode)
    }

    static func reduceRequest(action: ScheduleAction, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        switch action {
        case let action as TransitModeSelected:
            return ScheduleRequest(transitMode: action.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil, onlyOneRouteAvailable: false)
        default:
            return scheduleRequest
        }
    }
}
