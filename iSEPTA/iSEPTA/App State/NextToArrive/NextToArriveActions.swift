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

struct NextToArriveUpdateRequested: NextToArriveAction {
    let description = "User has a requested a refresh of Next to arrive data"
}

struct ClearNextToArriveData: NextToArriveAction {
    let description = "All next to arrive data should be cleared"
}

struct UpdateNextToArriveData: NextToArriveAction {
    let nextToArriveTrips: [NextToArriveTrip]
    let description = "New Data retrieved for Next to arrive"
}

struct NextToArrivePrerequisitesStatus: NextToArriveAction {
    let status: Bool
    let description = "Indicating whether prerequistes are complete to perform next to arrive request"
}
