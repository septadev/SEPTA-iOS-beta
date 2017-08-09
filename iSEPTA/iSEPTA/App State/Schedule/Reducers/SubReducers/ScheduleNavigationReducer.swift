// Septa. 2017

import Foundation
import UIKit
import ReSwift

struct ScheduleNavigationReducer {

    static func initNavigation() -> ViewControllerState {
        return ViewControllerState()
    }

    static func reduceNavigation(action _: ScheduleAction, scheduleNavigation: ViewControllerState) -> ViewControllerState {
        return scheduleNavigation
    }
}
