//
//  NextToArriveReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct NextToArriveReducer {
    static func main(action: Action, state: NextToArriveState?) -> NextToArriveState {
        if let state = state {
            switch action {
            case let action as ScheduleAction where action.targetForScheduleAction != .schedules :
                return reduceScheduleAction(action: action, state: state)
            case let action as NextToArriveAction:
                return reduceNextToArriveAction(action: action, state: state)
            default:
                return state
            }

        } else {
            return NextToArriveState()
        }
    }

    static func reduceScheduleAction(action: ScheduleAction, state: NextToArriveState) -> NextToArriveState {
        let scheduleState = ScheduleReducer.main(action: action, state: state.scheduleState)
        return NextToArriveState(scheduleState: scheduleState, nextToArriveTrips: state.nextToArriveTrips, updateRequested: state.updateRequested)
    }

    static func reduceNextToArriveAction(action: NextToArriveAction, state: NextToArriveState) -> NextToArriveState {
        var state = state
        switch action {
        case let action as NextToArriveUpdateRequested:
            state = reduceNextToArriveUpdateRequested(action: action, state: state)
        case let action as ClearNextToArriveData:
            state = reduceClearNextToArriveData(action: action, state: state)
        case let action as UpdateNextToArriveData:
            state = reduceUpdateNextToArriveData(action: action, state: state)
        case let action as NextToArrivePrerequisitesStatus:
            state = reduceNextToArrivePrerequisitesStatus(action: action, state: state)
        case let action as ViewScheduleDataInNextToArrive:
            state = reduceViewScheduleData(action: action, state: state)
        case let action as InsertNextToArriveScheduleRequest:
            state = reduceInsertNextToArriveScheduleRequest(action: action, state: state)
        default:
            break
        }

        return state
    }

    static func reduceNextToArriveUpdateRequested(action _: NextToArriveUpdateRequested, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: state.nextToArriveTrips, updateRequested: true)
    }

    static func reduceClearNextToArriveData(action _: ClearNextToArriveData, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: [NextToArriveTrip](), updateRequested: state.updateRequested)
    }

    static func reduceUpdateNextToArriveData(action: UpdateNextToArriveData, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: action.nextToArriveTrips, updateRequested: false)
    }

    static func reduceNextToArrivePrerequisitesStatus(action _: NextToArrivePrerequisitesStatus, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: state.nextToArriveTrips, updateRequested: true)
    }

    static func reduceViewScheduleData(action _: ViewScheduleDataInNextToArrive, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: store.state.scheduleState, nextToArriveTrips: state.nextToArriveTrips, updateRequested: state.updateRequested)
    }

    static func reduceInsertNextToArriveScheduleRequest(action: InsertNextToArriveScheduleRequest, state: NextToArriveState) -> NextToArriveState {
        let scheduleState = ScheduleState(scheduleRequest: action.scheduleRequest, scheduleData: ScheduleData(), scheduleStopEdit: ScheduleStopEdit())
        return NextToArriveState(scheduleState: scheduleState, nextToArriveTrips: state.nextToArriveTrips, updateRequested: state.updateRequested)
    }
}
