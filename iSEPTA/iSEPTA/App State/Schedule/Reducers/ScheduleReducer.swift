// Septa. 2017

import Foundation
import ReSwift

fileprivate typealias Nav = ScheduleNavigationReducer
fileprivate typealias Req = ScheduleRequestReducer
fileprivate typealias Data = ScheduleDataReducer

struct ScheduleReducer {

    static func main(action: Action, state: ScheduleState?) -> ScheduleState {

        if let newState = state {
            guard let action = action as? ScheduleAction,
                let scheduleRequest = newState.scheduleRequest,
                let scheduleData = newState.scheduleData,
                let scheduleNavigation = newState.scheduleNavigation

            else { return newState }
            return ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: scheduleData),
                scheduleNavigation: Nav.reduceNavigation(action: action, scheduleNavigation: scheduleNavigation)
            )

        } else {
            return ScheduleState(
                scheduleRequest: Req.initRequest(),
                scheduleData: Data.initScheduleData(),
                scheduleNavigation: Nav.initNavigation()
            )
        }
    }
}
