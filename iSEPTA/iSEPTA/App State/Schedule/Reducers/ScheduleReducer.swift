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
        if let action = action as? ScheduleAction, action.targetForScheduleAction.includesMe(.schedules) {
            return ScheduleReducer.main(action: action, state: state)
        } else {
            return state
        }
    }
}

struct ScheduleReducer {
    static func main(action: Action, state: ScheduleState?) -> ScheduleState {
        let scheduleState = state ?? ScheduleState()

        guard let action = action as? ScheduleAction else { return scheduleState }
        return reduceScheduleAction(action: action, state: scheduleState)
    }

    static func reduceScheduleAction(action: ScheduleAction, state: ScheduleState) -> ScheduleState {
        var scheduleState = state
        switch action {
        case let action as ReverseLoaded:
            scheduleState = reduceTripReverse(action: action, state: state)
        case let action as DatabaseLoaded:
            scheduleState = reduceDatabaseLoaded(action: action, state: state)
        case let action as CopyScheduleStateToTargetForScheduleAction:
            scheduleState = reduceCopyScheduleStateToTargetForScheduleAction(action: action, state: state)
        default:
            scheduleState = ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: scheduleState.scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: scheduleState.scheduleData),
                scheduleStopEdit: StopEdit.reduceStopEdit(action: action, scheduleStopEdit: scheduleState.scheduleStopEdit)
            )
        }
        return scheduleState
    }

    static func reduceTripReverse(action: ReverseLoaded, state: ScheduleState) -> ScheduleState {
        var scheduleData = ScheduleData()
        scheduleData.availableRoutes = state.scheduleData.availableRoutes
        return ScheduleState(
            scheduleRequest: action.scheduleRequest,
            scheduleData: scheduleData,
            scheduleStopEdit: ScheduleStopEdit()
        )
    }

    static func reduceDatabaseLoaded(action _: DatabaseLoaded, state: ScheduleState) -> ScheduleState {
        return ScheduleState(scheduleRequest: state.scheduleRequest, scheduleData: state.scheduleData, scheduleStopEdit: state.scheduleStopEdit)
    }

    static func reduceCopyScheduleStateToTargetForScheduleAction(action: CopyScheduleStateToTargetForScheduleAction, state _: ScheduleState) -> ScheduleState {
        return action.scheduleState
    }
}
