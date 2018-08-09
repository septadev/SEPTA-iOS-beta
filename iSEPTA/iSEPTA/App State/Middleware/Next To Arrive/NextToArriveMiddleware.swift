//
//  NextToArriveMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/23/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

let nextToArriveMiddleware: Middleware<AppState> = { _, _ in { next in
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
        case let action as NavigateToAlertDetailsFromNotification:
            generateActionsToNavigateToAlertDetailsFromNotifification(action: action)
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

        navigateToNextToArrive()
    }

    /// This action gets called when there is next to arrive data
    static func generateActionsToNavigateToSchedulesFromNextToArrive(action: NavigateToSchedulesFromNextToArrive) {
        let scheduleRequest = store.state.currentTargetForScheduleActionsScheduleRequest()
        let builder = NextToArriveMiddlewareScheduleRequestBuilder.sharedInstance
        builder.updateScheduleRequestInSchedules(nextToArriveTrip: action.nextToArriveTrip, scheduleRequest: scheduleRequest)
        switchTabsToSchedules()
        navigateToSchedules(routeId: scheduleRequest.selectedRoute?.routeId)
    }

    /// This action gets called when there is no Next to arrive Data
    static func generateActionsToNavigateToSchedulesFromNextToArriveScheduleRequest(action: NavigateToSchedulesFromNextToArriveScheduleRequest) {
        let builder = NextToArriveMiddlewareScheduleRequestBuilder.sharedInstance
        builder.copyScheduleRequestToSchedules(scheduleRequest: action.scheduleRequest)
        switchTabsToSchedules()
        navigateToSchedules(routeId: action.scheduleRequest.selectedRoute?.routeId)
    }

    static func generateActionsToNavigateToAlertDetailsFromSchedules(action: NavigateToAlertDetailsFromSchedules) {
        let copyScheduleState = CopyScheduleStateToTargetForScheduleAction(
            targetForScheduleAction: .alerts,
            scheduleState: action.scheduleState,
            description: "Importing Schedule State into alerts"
        )
        store.dispatch(copyScheduleState)

        navigateToAlertDetails()
    }

    static func generateActionsToNavigateToAlertDetailsFromNotifification(action: NavigateToAlertDetailsFromNotification) {
        let copyScheduleState = CopyScheduleStateToTargetForScheduleAction(
            targetForScheduleAction: .alerts,
            scheduleState: action.scheduleState,
            description: "Importing Schedule State into alerts"
        )
        store.dispatch(copyScheduleState)

        navigateToAlertDetails()
    }

    static func generateActionsToNavigateToAlertDetailsFromNextToArrive(action: NavigateToAlertDetailsFromNextToArrive) {
        let scheduleRequest = action.scheduleRequest
        let scheduleStateBuilder = NextToArriveMiddlewareScheduleStateBuilder.sharedInstance
        scheduleStateBuilder.updateScheduleStateInAlerts(nextToArriveStop: action.nextToArriveStop, scheduleRequest: scheduleRequest)

        navigateToAlertDetails()
    }

    static func navigateToAlertDetails() {
        let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "Switching Tabs to Alert details after importing schedule state")
        store.dispatch(switchTabsAction)

        let resetViewStateAction = ResetViewState(viewController: .alertDetailViewController, description: "Deep linking into Schedules from Next To Arrive")
        store.dispatch(resetViewStateAction)
    }

    static func navigateToSchedules(routeId: String?) {
        guard let routeId = routeId else { return }

        let viewController: ViewController = routeId == Route.allRailRoutesRouteId() ? .selectSchedules : .tripScheduleController
        let resetViewStateAction = ResetViewState(viewController: viewController, description: "Deep linking into Schedules from Next To Arrive")
        store.dispatch(resetViewStateAction)
    }

    static func navigateToNextToArrive() {
        let switchTabsAction = SwitchTabs(activeNavigationController: .nextToArrive, description: "Switching Tabs to Next to Arrive From Schedules")
        store.dispatch(switchTabsAction)

        let resetViewStateAction = ResetViewState(viewController: .nextToArriveController, description: "Navigating to Next to Arrive Detail from Schedules")
        store.dispatch(resetViewStateAction)
    }

    static func switchTabsToSchedules() {
        let switchTabsAction = SwitchTabs(activeNavigationController: .schedules, description: "Switching Tabs to Next to Arrive From Schedules")
        store.dispatch(switchTabsAction)
    }
}
