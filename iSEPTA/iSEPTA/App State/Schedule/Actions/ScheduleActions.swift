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

struct RouteToEdit: ScheduleAction {
    let description = "User wants to edit a route"
    let stopToEdit: StopToSelect
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
    let availableTrips: [Trip]?
    let description = "Now we have available trips for the user to consider"
    let error: String?
}

struct ScheduleTypeSelected: ScheduleAction {
    let scheduleType: ScheduleType
    let description = "change from weekday, saturday, sunday"
}

struct ReverseStops: ScheduleAction {
    let description = "User wants to reverse starts to the destination becomes the start and vice versa"
}

struct ReverseLoaded: ScheduleAction {
    let scheduleRequest: ScheduleRequest
    let trips: [Trip]
    let description = "Database has returned reverse stops"
    let error: String?
}

struct ResetSchedule: ScheduleAction {

    let description = "The User wants to reset the schedule"
}
