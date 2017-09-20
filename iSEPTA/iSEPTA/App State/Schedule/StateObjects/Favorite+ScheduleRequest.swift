//
//  Favorite+ScheduleRequest.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension Favorite {

    func scheduleRequest() -> ScheduleRequest {
        return ScheduleRequest(transitMode: transitMode, selectedRoute: selectedRoute, selectedStart: selectedStart, selectedEnd: selectedEnd, scheduleType: nil, reverseStops: false)
    }
}
