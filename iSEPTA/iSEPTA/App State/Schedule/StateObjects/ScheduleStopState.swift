//
//  ScheduleStopState.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct ScheduleStopState {
    let stops: [Stop]
    let updateMode: ScheduleUpdateMode
    init(stops: [Stop] = [Stop](), updateMode: ScheduleUpdateMode = .clearValues) {
        self.stops = stops
        self.updateMode = updateMode
    }
}

extension ScheduleStopState: Equatable {}
func == (lhs: ScheduleStopState, rhs: ScheduleStopState) -> Bool {
    var areEqual = true

    areEqual = lhs.stops == rhs.stops
    guard areEqual else { return false }

    areEqual = lhs.updateMode == rhs.updateMode
    guard areEqual else { return false }

    return areEqual
}
