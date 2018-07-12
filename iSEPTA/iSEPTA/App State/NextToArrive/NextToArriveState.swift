//
//  NextToArriveState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct NextToArriveState: Equatable {
    var scheduleState: ScheduleState
    var nextToArriveTrips: [NextToArriveTrip]
    var nextToArrivePrerequisiteStatus: NextToArrivePrerequisiteStatus
    var nextToArriveUpdateStatus: NextToArriveUpdateStatus

    var refreshDataRequested: Bool
    var reverseTripStatus: NextToArriveReverseTripStatus

    init(scheduleState: ScheduleState = ScheduleState(),
         nextToArriveTrips: [NextToArriveTrip] = [NextToArriveTrip](),
         nextToArrivePrerequisiteStatus: NextToArrivePrerequisiteStatus = .missingPrerequisites,
         nextToArriveUpdateStatus: NextToArriveUpdateStatus = .idle,
         refreshDataRequested: Bool = false,
         reverseTripStatus: NextToArriveReverseTripStatus = .noReverse
    ) {
        self.scheduleState = scheduleState
        self.nextToArriveTrips = nextToArriveTrips
        self.nextToArrivePrerequisiteStatus = nextToArrivePrerequisiteStatus
        self.nextToArriveUpdateStatus = nextToArriveUpdateStatus
        self.refreshDataRequested = refreshDataRequested
        self.reverseTripStatus = reverseTripStatus
    }
}
