// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

enum TargetForScheduleAction {
    case schedules
    case nextToArrive
    case both
}

protocol ScheduleAction: SeptaAction {
    var targetForScheduleAction: TargetForScheduleAction { get }
}

struct TransitModeSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let transitMode: TransitMode
    let description: String
}

struct DatabaseLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "The database has been moved and is the right place"
}

struct RoutesLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let routes: [Route]
    let error: String?
    let description = "Routes for viewing are now available"
}

struct ClearRoutes: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "Clearing out routes in preparation for a new query to run"
}

struct RouteSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let selectedRoute: Route
    let description = "User Selected a route"
}

struct RouteToEdit: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "User wants to edit a route"
    let stopToEdit: StopToSelect
}

struct CurrentStopToEdit: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "User Selected a route"
    let stopToEdit: StopToSelect
}

struct TripStartsLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let availableStarts: [Stop]
    let description = "Loading available trip starting points for direction"
    let error: String?
}

struct TripStartSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let selectedStart: Stop
    let description = "The user has selected a stop"
}

struct ClearTripStarts: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "Clearing out starting stops in preparation for a new query"
}

struct TripEndsLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let availableStops: [Stop]
    let description = "Loading available trip ending points for direction"
    let error: String?
}

struct ClearTripEnds: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "Clearing out ending stops in preparation for a new query"
}

struct TripEndSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let selectedEnd: Stop?
    let description = "User picked a stop for the trip"
}

struct TripsLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let availableTrips: [Trip]
    let description = "Now we have available trips for the user to consider"
    let error: String?
}

struct ClearTrips: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "Clearing out trips in preparation for a new query"
}

struct ScheduleTypeSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let scheduleType: ScheduleType
    let description = "change from weekday, saturday, sunday"
}

struct ReverseStops: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let description = "User wants to reverse starts to the destination becomes the start and vice versa"
}

struct ReverseLoaded: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let scheduleRequest: ScheduleRequest
    let trips: [Trip]
    let description = "Database has returned reverse stops"
    let error: String?
}

struct StopSearchModeChanged: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let searchMode: StopEditSearchMode
    let description = "User has toggled segmented control"
}

struct ResetSchedule: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction

    let description = "The User wants to reset the schedule"
}

struct AddressSelected: ScheduleAction {
    let targetForScheduleAction: TargetForScheduleAction
    let selectedAddress: DisplayAddress
    let description = "The user has selected an address to search near"
}
