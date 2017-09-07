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
            return NextToArriveState(
                scheduleState: reduceScheduleState(action: action, state: state.scheduleState)
            )
        } else {
            return NextToArriveState()
        }
    }

    static func reduceScheduleState(action: Action, state: ScheduleState) -> ScheduleState {
        if let action = action as? ScheduleAction, action.targetForScheduleAction != .schedules {
            return ScheduleReducer.main(action: action, state: state)
        } else {
            return state
        }
    }

    static func reduceNextToArriveAction(action _: NextToArriveAction, state: NextToArriveState) -> NextToArriveState {

        return state
    }
}
