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
        case let action as NavigateToAlertDetailsFromSchedules:
            generateActionsToNavigateToAlertDetailsFromSchedules(action: action)
        case let action as NavigateToAlertDetailsFromNextToArrive:
            generateActionsToNavigateToAlertDetailsFromNextToArrive(action: action)
        case let action as NavigateToSchedulesFromNextToArriveScheduleRequest:
            generateActionsToNavigateToSchedulesFromNextToArriveScheduleRequest(action: action)
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

        var navigationStackState = buildNavigationStackState(viewControllers: [.nextToArriveController])
        var viewStackAction = InitializeNavigationState(navigationController: .nextToArrive, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from schedules to Next To Arrive")
        store.dispatch(viewStackAction)

        navigationStackState = buildNavigationStackState(viewControllers: [.nextToArriveController, .nextToArriveDetailController])
        viewStackAction = InitializeNavigationState(navigationController: .nextToArrive, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from schedules to Next To Arrive")
        store.dispatch(viewStackAction)

        let switchTabsAction = SwitchTabs(activeNavigationController: .nextToArrive, description: "Switching Tabs to Next to Arrive From Schedules")
        store.dispatch(switchTabsAction)
    }

    static func generateActionsToNavigateToSchedulesFromNextToArrive(action: NavigateToSchedulesFromNextToArrive) {

        let scheduleRequest = store.state.targetForScheduleActionsScheduleRequest()
        let builder = NextToArriveMiddlewareScheduleRequestBuilder.sharedInstance
        builder.updateScheduleRequestInSchedules(nextToArriveTrip: action.nextToArriveTrip, scheduleRequest: scheduleRequest)

        let delayTime: Double = scheduleRequest.transitMode == .rail ? 2 : 0.5

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {

            let navigationStackState = buildNavigationStackState(viewControllers: [.selectSchedules, .tripScheduleController])
            let viewStackAction = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from Next To Arrive to Schedules")
            store.dispatch(viewStackAction)

            let switchTabsAction = SwitchTabs(activeNavigationController: .schedules, description: "Switching Tabs to Next to Arrive From Schedules")
            store.dispatch(switchTabsAction)
        }
    }

    static func generateActionsToNavigateToSchedulesFromNextToArriveScheduleRequest(action: NavigateToSchedulesFromNextToArriveScheduleRequest) {

        let builder = NextToArriveMiddlewareScheduleRequestBuilder.sharedInstance
        builder.copyScheduleRequestToSchedules(scheduleRequest: action.scheduleRequest)

        let navigationStackState = buildNavigationStackState(viewControllers: [.selectSchedules, .tripScheduleController])
        let viewStackAction = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState, description: "Setting Navigation Stack State prior to moving from Next To Arrive to Schedules")
        store.dispatch(viewStackAction)

        let switchTabsAction = SwitchTabs(activeNavigationController: .schedules, description: "Switching Tabs to Next to Arrive From Schedules")
        store.dispatch(switchTabsAction)
    }

    static func generateActionsToNavigateToAlertDetailsFromSchedules(action: NavigateToAlertDetailsFromSchedules) {
        let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "Switching Tabs to Alert details after importing schedule state")
        store.dispatch(switchTabsAction)

        let copyScheduleState = CopyScheduleStateToTargetForScheduleAction(
            targetForScheduleAction: .alerts,
            scheduleState: action.scheduleState,
            description: "Importing Schedule State into alerts"
        )
        store.dispatch(copyScheduleState)

        let navigationStackState = buildNavigationStackState(viewControllers: [.alertsViewController, .alertDetailViewController])
        let viewStackAction = InitializeNavigationState(navigationController: .alerts, navigationStackState: navigationStackState, description: "Setting Navigation Stack State with imported schedule state")
        store.dispatch(viewStackAction)
    }

    static func generateActionsToNavigateToAlertDetailsFromNextToArrive(action: NavigateToAlertDetailsFromNextToArrive) {
        let scheduleRequest = action.scheduleRequest
        let scheduleStateBuilder = NextToArriveMiddlewareScheduleStateBuilder.sharedInstance
        scheduleStateBuilder.updateScheduleStateInAlerts(nextToArriveStop: action.nextToArriveStop, scheduleRequest: scheduleRequest)
    }

    static func buildNavigationStackState(viewControllers: [ViewController]) -> NavigationStackState {
        return NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
    }
}
