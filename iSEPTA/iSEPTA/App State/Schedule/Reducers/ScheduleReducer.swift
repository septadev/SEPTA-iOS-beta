// Septa. 2017

import Foundation
import ReSwift

fileprivate typealias Req = ScheduleRequestReducer
fileprivate typealias Data = ScheduleDataReducer
fileprivate typealias StopEdit = ScheduleStopEditReducer

struct ScheduleStateReducer {
    static func main(action: Action, state: ScheduleState?) -> ScheduleState {
        if let state = state {
            return reduceScheduleState(action: action, state: state)
        } else {
            return ScheduleState()
        }
    }

    static func reduceScheduleState(action: Action, state: ScheduleState) -> ScheduleState {
        if let action = action as? ScheduleAction, action.targetForScheduleAction != .nextToArrive {
            return ScheduleReducer.main(action: action, state: state)
        } else {
            return state
        }
    }
}

struct ScheduleReducer {

    static func main(action: Action, state: ScheduleState?) -> ScheduleState {
        /// Handle the edge case of trip reverses
        if let action = action as? ReverseLoaded, let state = state {
            return reduceTripReverse(action: action, state: state)
        }
        /// if the state already exists
        if let newState = state {
            /// if the action is a schedule action
            guard let action = action as? ScheduleAction else { return newState }
            return ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: newState.scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: newState.scheduleData),
                scheduleStopEdit: StopEdit.reduceStopEdit(action: action, scheduleStopEdit: newState.scheduleStopEdit)
            )

        } else {
            return ScheduleState()
        }
    }

    static func reduceTripReverse(action: ReverseLoaded, state: ScheduleState) -> ScheduleState {
        return ScheduleState(
            scheduleRequest: action.scheduleRequest,
            scheduleData: ScheduleData(availableRoutes: state.scheduleData.availableRoutes),
            scheduleStopEdit: ScheduleStopEdit()
        )
    }
}
