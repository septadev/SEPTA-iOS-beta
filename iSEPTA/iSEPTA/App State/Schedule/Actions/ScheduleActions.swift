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
    let description: String
}

struct RouteSelected: ScheduleAction {
    let selectedRoute: Route
    let description: String
}

struct TripStartsLoaded: ScheduleAction, Codable {
    let availableStarts: [Stop]?
    let description = "Loading available route starting points for direction"
    let error: String?
}

struct TripStartSelected: ScheduleAction, Codable {
    let selectedStart: Stop
    let description = "The user has selected a stop"
}
