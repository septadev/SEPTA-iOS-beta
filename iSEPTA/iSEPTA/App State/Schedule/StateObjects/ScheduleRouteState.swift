//
//  ScheduleRouteState.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct ScheduleRouteState {
    let routes: [Route]
    let updateMode: ScheduleUpdateMode

    init(routes: [Route] = [Route](), updateMode: ScheduleUpdateMode = .clearValues) {
        self.routes = routes
        self.updateMode = updateMode
    }
}

extension ScheduleRouteState: Equatable {}
func == (lhs: ScheduleRouteState, rhs: ScheduleRouteState) -> Bool {
    var areEqual = true

    areEqual = lhs.routes == rhs.routes
    guard areEqual else { return false }

    areEqual = lhs.updateMode == rhs.updateMode
    guard areEqual else { return false }

    return areEqual
}
