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
    let nextToArriveTrips: [NextToArriveTrip]
    let updateRequested: Bool
    init(scheduleState: ScheduleState = ScheduleState(), nextToArriveTrips: [NextToArriveTrip] = [NextToArriveTrip](), updateRequested: Bool = false) {
        self.scheduleState = scheduleState
        self.nextToArriveTrips = nextToArriveTrips
        self.updateRequested = updateRequested
    }
}

extension NextToArriveState: Equatable {}
func ==(lhs: NextToArriveState, rhs: NextToArriveState) -> Bool {
    var areEqual = true

    areEqual = lhs.scheduleState == rhs.scheduleState
    guard areEqual else { return false }

    areEqual = lhs.nextToArriveTrips == rhs.nextToArriveTrips
    guard areEqual else { return false }

    return areEqual
}
