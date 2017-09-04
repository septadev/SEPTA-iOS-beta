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

struct NextToArriveTransitModeSelected: NextToArriveAction {

    let transitMode: TransitMode
    let description: String
}

struct NextToArriveDatabaseLoaded: NextToArriveAction {
    let description = "The database has been moved and is the right place"
}

struct NextToArriveRoutesLoaded: NextToArriveAction {
    let routes: [Route]
    let error: String?
    let description = "Routes for viewing are now available"
}

struct NextToArriveClearRoutes: NextToArriveAction {
    let description = "Clearing out routes in preparation for a new query to run"
}

struct NextToArriveRouteSelected: NextToArriveAction {
    let selectedRoute: Route
    let description = "User Selected a route"
}

struct NextToArriveRouteToEdit: NextToArriveAction {
    let description = "User wants to edit a route"
    let stopToEdit: StopToSelect
}

struct NextToArriveCurrentStopToEdit: NextToArriveAction {
    let description = "User Selected a route"
    let stopToEdit: StopToSelect
}

struct NextToArriveTripStartsLoaded: NextToArriveAction {
    let availableStarts: [Stop]
    let description = "Loading available trip starting points for direction"
    let error: String?
}

struct NextToArriveTripStartSelected: NextToArriveAction {
    let selectedStart: Stop
    let description = "The user has selected a stop"
}

struct NextToArriveClearTripStarts: NextToArriveAction {
    let description = "Clearing out starting stops in preparation for a new query"
}

struct NextToArriveTripEndsLoaded: NextToArriveAction {
    let availableStops: [Stop]
    let description = "Loading available trip ending points for direction"
    let error: String?
}

struct NextToArriveClearTripEnds: NextToArriveAction {
    let description = "Clearing out ending stops in preparation for a new query"
}

struct NextToArriveTripEndSelected: NextToArriveAction {
    let selectedEnd: Stop?
    let description = "User picked a stop for the trip"
}

struct NextToArriveTripsLoaded: NextToArriveAction {
    let availableTrips: [Trip]
    let description = "Now we have available trips for the user to consider"
    let error: String?
}

struct NextToArriveClearTrips: NextToArriveAction {
    let description = "Clearing out trips in preparation for a new query"
}

struct NextToArriveScheduleTypeSelected: NextToArriveAction {
    let scheduleType: ScheduleType
    let description = "change from weekday, saturday, sunday"
}

struct NextToArriveReverseStops: NextToArriveAction {
    let description = "User wants to reverse starts to the destination becomes the start and vice versa"
}

struct NextToArriveReverseLoaded: NextToArriveAction {
    let scheduleRequest: ScheduleRequest
    let trips: [Trip]
    let description = "Database has returned reverse stops"
    let error: String?
}

struct NextToArriveStopSearchModeChanged: NextToArriveAction {
    let searchMode: StopEditSearchMode
    let description = "User has toggled segmented control"
}

struct NextToArriveResetSchedule: NextToArriveAction {

    let description = "The User wants to reset the schedule"
}

struct NextToArriveAddressSelected: NextToArriveAction {
    let selectedAddress: DisplayAddress
    let description = "The user has selected an address to search near"
}
