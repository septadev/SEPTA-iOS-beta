// Septa. 2017

import Foundation
import ReSwift

fileprivate typealias Req = ScheduleRequestReducer
fileprivate typealias Data = ScheduleDataReducer
fileprivate typealias StopEdit = ScheduleStopEditReducer

struct ScheduleReducer {

    static func main(action: Action, state: ScheduleState?) -> ScheduleState {
        /// Handle the edge case of trip reverses
        if let action = action as? ReverseLoaded, let state = state {
            return reduceTripReverse(action: action, state: state)
        }
        /// if the state already exists
        if let newState = state {
            /// if the action is a schedule action
            guard let action = action as? ScheduleAction,
                let scheduleRequest = newState.scheduleRequest,
                let scheduleData = newState.scheduleData,
                let scheduleStopEdit = newState.scheduleStopEdit

            else { return newState }
            return ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: scheduleData),
                scheduleStopEdit: StopEdit.reduceStopEdit(action: action, scheduleStopEdit: scheduleStopEdit)
            )
            /// if schedule state does not exist, run through the init
        } else {
            return ScheduleState(
                scheduleRequest: Req.initRequest(),
                scheduleData: Data.initScheduleData(),
                scheduleStopEdit: StopEdit.initStopEdit()
            )
        }
    }

    static func reduceTripReverse(action: ReverseLoaded, state: ScheduleState) -> ScheduleState {
        return ScheduleState(
            scheduleRequest: action.scheduleRequest,
            scheduleData: ScheduleData(availableRoutes: state.scheduleData?.availableRoutes, availableStarts: nil, availableStops: nil, availableTrips: nil, errorString: action.error)
        )
    }
}
