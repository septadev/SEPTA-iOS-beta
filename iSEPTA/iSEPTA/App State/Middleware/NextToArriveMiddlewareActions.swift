// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol MiddlewareAction: SeptaAction {}

struct NavigateToNextToArriveFromSchedules: MiddlewareAction {

    let description = "Navigate to Next To Arrive From Schedules"
}
