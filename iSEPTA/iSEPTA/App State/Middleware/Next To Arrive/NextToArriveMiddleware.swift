//
//  NextToArriveMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/23/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaRest
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
        let scheduleRequest = ScheduleRequest(transitMode: .rail)

        let copyScheduleAction = CopyScheduleRequestToTargetForScheduleAction(targetForScheduleAction: .nextToArrive, scheduleRequest: scheduleRequest, description: "Handling a delay Notification")
        store.dispatch(copyScheduleAction)

        let switchTabsAction = SwitchTabs(activeNavigationController: .nextToArrive, description: "Switching to Next to Arrive from a delay notification")
        store.dispatch(switchTabsAction)

        let notif = action.notification
        let tripId = notif.vehicleId
        guard notif.expires > Date() else { return }
        let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

        func modalShortcut(details: RealTimeArrivalDetail) {
            DispatchQueue.main.async {
                let matchingStop = NextToArriveStop(transitMode: .rail, routeId: notif.routeId, routeName: details.line ?? "", tripId: Int(notif.vehicleId), arrivalTime: Date(), departureTime: Date(), lastStopId: nil, lastStopName: nil, delayMinutes: nil, direction: nil, vehicleLocationCoordinate: nil, vehicleIds: nil, hasRealTimeData: true, service: nil)
                let updateAction = UpdateTripDetails(tripDetails: matchingStop)
                store.dispatch(updateAction)

                let modalAction = PresentModal(viewController: .tripDetailModalController, description: "Not enough info to display trip detail info in the flow")
                store.dispatch(modalAction)
            }
        }

        client.getRealTimeRailArrivalDetail(tripId: tripId).then { details -> Void in
            guard let details = details else { return }
            guard let destinationStation = details.destinationStation,
                let nextStopStation = details.nextstopStation else { modalShortcut(details: details); return }

            FindStopByStopNameCommand.sharedInstance.stop(stopName: destinationStation) { stops, _ in
                guard let stops = stops, let destinationStop = stops.first else { modalShortcut(details: details); return }

                FindStopByStopNameCommand.sharedInstance.stop(stopName: nextStopStation) { stops, _ in
                    guard let stops = stops, let nextStop = stops.first else { modalShortcut(details: details); return }

                    let selectedRoute = Route.allRailRoutesRoute()

                    let scheduleRequest = ScheduleRequest(transitMode: .rail, selectedRoute: selectedRoute, selectedStart: nextStop, selectedEnd: destinationStop)

                    let copyScheduleAction = CopyScheduleRequestToTargetForScheduleAction(targetForScheduleAction: .nextToArrive, scheduleRequest: scheduleRequest, description: "Handling a delay Notification")
                    store.dispatch(copyScheduleAction)

                    let resetViewState = ResetViewState(viewController: .nextToArriveDetailController, description: "loading up trip detail")
                    store.dispatch(resetViewState)

                    NextToArriveDetailForDelayNotification.sharedInstance.waitForRealTimeData(tripId: tripId)
                }
            }

        }.catch { error in
            print(error.localizedDescription)
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
