// Septa. 2017

import Foundation
import ReSwift

fileprivate typealias Req = ScheduleRequestReducer
fileprivate typealias Data = ScheduleDataReducer

struct ScheduleReducer {

    static func main(action: Action, state: ScheduleState?) -> ScheduleState {

        if let newState = state {
            guard let action = action as? ScheduleAction,
                let scheduleRequest = newState.scheduleRequest,
                let scheduleData = newState.scheduleData

            else { return newState }
            return ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: scheduleData)
            )

        } else {
            return ScheduleState(
                scheduleRequest: Req.initRequest(),
                scheduleData: Data.initScheduleData()
            )
        }
    }
}
