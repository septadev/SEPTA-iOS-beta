// Septa. 2017

import Foundation
import ReSwift

struct ScheduleRequestReducer {

    static func initRequest() -> ScheduleRequest {
        let transitMode = stateProviders.preferenceProvider.retrievePersistedState().transitMode
        return ScheduleRequest(transitMode: transitMode)
    }

    static func reduceRequest(action _: ScheduleAction, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return scheduleRequest
    }
}
