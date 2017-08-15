// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol ScheduleAction: SeptaAction {}

struct TransitModeSelected: ScheduleAction {

    let transitMode: TransitMode
    let description: String
}

struct RoutesLoaded: ScheduleAction {
    let routes: [Route]?
    let error: String?
    let description = "Routes for viewing are now available"
}

struct RouteSelected: ScheduleAction {
    let selectedRoute: Route
    let description = "User Selected a route"
}

struct CurrentStopToEdit: ScheduleAction {
    let description = "User Selected a route"
    let stopToEdit: StopToSelect
}

struct TripStartsLoaded: ScheduleAction {
    let availableStarts: [Stop]?
    let description = "Loading available trip starting points for direction"
    let error: String?
}

struct TripStartSelected: ScheduleAction {
    let selectedStart: Stop
    let description = "The user has selected a stop"
}

struct TripEndsLoaded: ScheduleAction {
    let availableStops: [Stop]?
    let description = "Loading available trip ending points for direction"
    let error: String?
}

struct TripEndSelected: ScheduleAction {
    let selectedEnd: Stop?
    let description = "User picked a stop for the trip"
}

struct TripsLoaded: ScheduleAction {
    let availableTrips: [Trip]
    let description = "Now we have available trips for the user to consider"
    let error: String?
}
