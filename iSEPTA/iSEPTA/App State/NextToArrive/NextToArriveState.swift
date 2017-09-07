//
//  NextToArriveState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct NextToArriveState {
    let scheduleState: ScheduleState
    let nextToArriveTrip: NextToArriveTrip?

    init(scheduleState: ScheduleState, nextToArriveTrip: NextToArriveTrip? = nil) {
        self.scheduleState = scheduleState
        self.nextToArriveTrip = nextToArriveTrip
    }
}

extension NextToArriveState: Equatable {}
func ==(lhs: NextToArriveState, rhs: NextToArriveState) -> Bool {
    var areEqual = true

    areEqual = lhs.scheduleState == rhs.scheduleState
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.nextToArriveTrip, newValue: rhs.nextToArriveTrip).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
