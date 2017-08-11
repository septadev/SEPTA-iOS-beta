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

    let route: Route
    let description: String
}
