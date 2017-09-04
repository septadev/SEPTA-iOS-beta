//
//  NextToArriveState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct NextToArriveState {
    let scheduleState: ScheduleState
    init(scheduleState: ScheduleState = ScheduleState()) {
        self.scheduleState = scheduleState
    }
}

extension NextToArriveState: Equatable {}
func ==(lhs: NextToArriveState, rhs: NextToArriveState) -> Bool {
    var areEqual = true

    areEqual = lhs.scheduleState == rhs.scheduleState
    guard areEqual else { return false }

    return areEqual
}
