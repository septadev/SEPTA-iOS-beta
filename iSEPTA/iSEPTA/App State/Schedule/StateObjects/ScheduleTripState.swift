//
//  ScheduleTripState.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct ScheduleTripState {
    let trips: [Trip]
    let updateMode: ScheduleUpdateMode
    init(trips: [Trip] = [Trip](), updateMode: ScheduleUpdateMode = .clearValues) {
        self.trips = trips
        self.updateMode = updateMode
    }
}

extension ScheduleTripState: Equatable {}
func == (lhs: ScheduleTripState, rhs: ScheduleTripState) -> Bool {
    var areEqual = true

    areEqual = lhs.trips == rhs.trips
    guard areEqual else { return false }

    areEqual = lhs.updateMode == rhs.updateMode
    guard areEqual else { return false }

    return areEqual
}
