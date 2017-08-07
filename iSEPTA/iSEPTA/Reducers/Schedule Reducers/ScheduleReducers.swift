//
//  ScheduleReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class ScheduleReducers {

    class func main(action _: Action, state _: ScheduleState?) -> ScheduleState {

        return ScheduleState(transitMode: .bus, routes: nil, selectedRoute: nil, availableStarts: nil, selectedStart: nil, availableStops: nil, selectedStop: nil, availableTrips: nil)
    }

    // First job is to get the transit modes right
}
