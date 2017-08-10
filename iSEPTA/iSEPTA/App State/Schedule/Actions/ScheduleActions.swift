// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol ScheduleAction: Action {}

struct TransitModeSelected: ScheduleAction {

    let transitMode: TransitMode
}

struct DisplayRoutes: ScheduleAction {}

struct RoutesLoaded: ScheduleAction {
    let routes: [Route]?
    let error: Error?
}
