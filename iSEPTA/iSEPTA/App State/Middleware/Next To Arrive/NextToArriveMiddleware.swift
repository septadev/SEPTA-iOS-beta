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
        case let action as NavigateToNextToArriveFromDelayNotification:
            generateActionsToNavigateToNextToArriveFromDelayNotification(action: action)
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
        let transitMode = action.notification.transitMode
        let routeId = action.notification.routeId
        RoutesCommand.sharedInstance.routes(forTransitMode: transitMode) { routes, _ in
            guard let route = routes?.first(where: { $0.routeId == routeId }) else { return }

            let scheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: route)
            let scheduleState = ScheduleState(scheduleRequest: scheduleRequest, scheduleData: ScheduleData(), scheduleStopEdit: ScheduleStopEdit())

            let action = CopyScheduleStateToTargetForScheduleAction(
                targetForScheduleAction: .alerts,
                scheduleState: scheduleState,
                description: "Importing Schedule State into alerts"
            )
            store.dispatch(action)
            navigateToAlertDetails()
        }
    }

    static func generateActionsToNavigateToAlertDetailsFromNextToArrive(action: NavigateToAlertDetailsFromNextToArrive) {
        let scheduleRequest = action.scheduleRequest
        let scheduleStateBuilder = NextToArriveMiddlewareScheduleStateBuilder.sharedInstance
        scheduleStateBuilder.updateScheduleStateInAlerts(nextToArriveStop: action.nextToArriveStop, scheduleRequest: scheduleRequest)

        navigateToAlertDetails()
    }

    static func generateActionsToNavigateToNextToArriveFromDelayNotification(action: NavigateToNextToArriveFromDelayNotification) {
        let notif = action.notification
        RoutesCommand.sharedInstance.routes(forTransitMode: .rail) { routes, _ in
            guard let routes = routes,
                let selectedRoute = routes.first(where: { $0.routeId == notif.routeId }) else { return }

            StopsForDelayNotification.sharedInstance.stops(routeId: notif.routeId, tripId: notif.vehicleId, date: Date(), endStopId: notif.destinationStopId) { stops, _ in
                guard let stops = stops, stops.count == 2 else { return }

                let scheduleRequest = ScheduleRequest(transitMode: notif.transitMode, selectedRoute: selectedRoute, selectedStart: stops[0], selectedEnd: stops[1], scheduleType: nil, reverseStops: false)

                let action = CopyScheduleRequestToTargetForScheduleAction(targetForScheduleAction: .nextToArrive, scheduleRequest: scheduleRequest, description: "Jumping to Next To Arrive from a delay notification")
                store.dispatch(action)

                let refreshAction = NextToArriveRefreshDataRequested(refreshUpdateRequested: true)
                store.dispatch(refreshAction)

                store.dispatch(SwitchTabs(activeNavigationController: .nextToArrive, description: "Switching Tabs to NTA to show a delay notification"))

                store.dispatch(ResetViewState(viewController: .nextToArriveDetailController, description: "Heading to Next to Arrive"))

                NextToArriveDetailForDelayNotification.sharedInstance.waitForRealTimeData(routeId: notif.routeId, tripId: notif.vehicleId)
            }
        }
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
