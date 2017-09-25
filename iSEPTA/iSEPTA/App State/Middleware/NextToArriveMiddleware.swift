//
//  NextToArriveMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/23/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

let nextToArriveMiddleware: Middleware<Any> = { _, _ in { next in
    return { action in
        if let action = action as? NextToArriveMiddlewareAction {
            NextToArriveMiddleware.generateActions(action: action)
        } else {

            return next(action)
        }
    }
}
}

class NextToArriveMiddleware {

    static func generateActions(action: NextToArriveMiddlewareAction) {
        switch action {
        case let action as NavigateToNextToArriveFromSchedules:
            generateActionsToNavigateToNextToArriveFromSchedules(action: action)
        case let action as NavigateToSchedulesFromNextToArrive:
            generateActionsToNavigateToSchedulesFromNextToArrive(action: action)
        default:
            break
        }
    }

    static func generateActionsToNavigateToNextToArriveFromSchedules(action _: NavigateToNextToArriveFromSchedules) {

        let copyScheduleRequest = CopyScheduleRequestToTargetForScheduleAction(
            targetForScheduleAction: .nextToArrive,
            scheduleRequest: store.state.scheduleState.scheduleRequest,
            description: "Copying Schedule Request from schedules to Next To Arrive")
        store.dispatch(copyScheduleRequest)

        let navigationStackState = buildNavigationStackState(viewControllers: [.nextToArriveController, .nextToArriveDetailController])
        let viewStackAction = InitializeNavigationState(navigationController: .nextToArrive, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from schedules to Next To Arrive")
        store.dispatch(viewStackAction)

        let switchTabsAction = SwitchTabs(activeNavigationController: .nextToArrive, description: "Switching Tabs to Next to Arrive From Schedules")
        store.dispatch(switchTabsAction)
    }

    static func generateActionsToNavigateToSchedulesFromNextToArrive(action: NavigateToSchedulesFromNextToArrive) {

        let scheduleRequest = store.state.targetForScheduleActionsScheduleRequest()
        let builder = NextToArriveRailScheduleRequestBuilder.sharedInstance
        builder.updateScheduleRequestInSchedules(nextToArriveTrip: action.nextToArriveTrip, scheduleRequest: scheduleRequest)

        let delayTime: Double = scheduleRequest.transitMode == .rail ? 2 : 0

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {

            let navigationStackState = buildNavigationStackState(viewControllers: [.selectSchedules, .tripScheduleController])
            let viewStackAction = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from Next To Arrive to Schedules")
            store.dispatch(viewStackAction)

            let switchTabsAction = SwitchTabs(activeNavigationController: .schedules, description: "Switching Tabs to Next to Arrive From Schedules")
            store.dispatch(switchTabsAction)
        }
    }

    static func buildNavigationStackState(viewControllers: [ViewController]) -> NavigationStackState {
        return NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
    }
}
