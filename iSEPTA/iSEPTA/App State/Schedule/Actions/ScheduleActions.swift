// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol ScheduleAction: Action {}

struct TransitModeSelected: ScheduleAction {

    let transitMode: TransitMode
}

struct RoutesLoaded: ScheduleAction {

    let routes: [Route]?
    let error: Error?
}

struct RouteSelected: ScheduleAction {

    let route: Route
}
