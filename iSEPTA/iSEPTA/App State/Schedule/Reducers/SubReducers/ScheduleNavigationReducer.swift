// Septa. 2017

import Foundation
import UIKit
import ReSwift

struct ScheduleNavigationReducer {

    static func initNavigation() -> ViewControllerState {
        return ViewControllerState()
    }

    static func reduceNavigation(action: ScheduleAction, scheduleNavigation: ViewControllerState) -> ViewControllerState {

        switch action {
            case let action as? ScheduleActions.DisplayRoutes:
            let newRouter = ViewControllerState(requestedViewController: )

        }

        return scheduleNavigation
    }
}

