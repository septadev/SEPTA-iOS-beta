//
//  NextToArriveScheduleActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol NextToArriveAction: SeptaAction {}

struct NextToArrivePrerequisteStatusChanged: NextToArriveAction {
    let newStatus: NextToArrivePrerequisiteStatus
    let description = "The underlying dependencies for the NTA service call have changed"
}

struct NextToArriveRefreshDataRequested: NextToArriveAction {
    let refreshUpdateRequested: Bool
    let description = "User has a requested a refresh of Next to arrive data"
}

struct ClearNextToArriveData: NextToArriveAction {
    let description = "All next to arrive data should be cleared"
}

struct UpdateNextToArriveStatusAndData: NextToArriveAction {
    let nextToArriveUpdateStatus: NextToArriveUpdateStatus
    let nextToArriveTrips: [NextToArriveTrip]
    let refreshDataRequested: Bool
    let description = "Provider reporting on the status of the update"
}

struct ViewScheduleDataInNextToArrive: NextToArriveAction {

    let description = "Jumping from schedules to next to arrive"
}

struct InsertNextToArriveScheduleRequest: NextToArriveAction {
    let scheduleRequest: ScheduleRequest
    let description = "force a new schedule request into NTA"
}
