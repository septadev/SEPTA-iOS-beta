//
//  NextToArriveRailScheduleRequestBuilder.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/24/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class NextToArriveMiddlewareScheduleStateBuilder {
    static let sharedInstance = NextToArriveMiddlewareScheduleStateBuilder()
    private init() {}

    let targetForScheduleAction: TargetForScheduleAction = .alerts

    func updateScheduleStateInAlerts(nextToArriveStop: NextToArriveStop, scheduleRequest: ScheduleRequest) {
        if scheduleRequest.transitMode == .rail {
            setRoute(nextToArriveStop: nextToArriveStop, scheduleRequest: scheduleRequest)
        } else {
            copyScheduleStateToAlerts(scheduleRequest: scheduleRequest)
            
            let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "Switching Tabs to Alert details after importing schedule state")
            store.dispatch(switchTabsAction)
            
            let navigationStackState = buildNavigationStackState(viewControllers: [.alertsViewController, .alertDetailViewController])
            let viewStackAction = InitializeNavigationState(navigationController: .alerts, navigationStackState: navigationStackState, description: "Setting Navigation Stack to show alert details")
            store.dispatch(viewStackAction)
        }
    }

    private func setRoute(nextToArriveStop: NextToArriveStop, scheduleRequest: ScheduleRequest) {
        let routeId = nextToArriveStop.routeId
        RoutesCommand.sharedInstance.routes(forTransitMode: .rail) { [weak self] routes, _ in
            guard let strongSelf = self else { return }
            let routes = routes ?? [Route]()
            if let route = routes.filter({ $0.routeId == routeId }).first {

                let routeUpdatedScheduleRequest = ScheduleRequest(
                    transitMode: .rail,
                    selectedRoute: route,
                    selectedStart: scheduleRequest.selectedStart,
                    selectedEnd: scheduleRequest.selectedEnd,
                    scheduleType: .mondayThroughThursday,
                    reverseStops: false)

                strongSelf.copyScheduleStateToAlerts(scheduleRequest: routeUpdatedScheduleRequest)
            }
        }
    }

    func copyScheduleStateToAlerts(scheduleRequest: ScheduleRequest) {
        let scheduleState = ScheduleState(scheduleRequest: scheduleRequest, scheduleData: ScheduleData(), scheduleStopEdit: ScheduleStopEdit())
        let copyAction = CopyScheduleStateToTargetForScheduleAction(targetForScheduleAction: .alerts, scheduleState: scheduleState, description: "Copying Schedule State to Alerts")
        store.dispatch(copyAction)
        
        let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "Switching Tabs to Alert details after importing schedule state")
        store.dispatch(switchTabsAction)
        
        let navigationStackState = buildNavigationStackState(viewControllers: [.alertsViewController, .alertDetailViewController])
        let viewStackAction = InitializeNavigationState(navigationController: .alerts, navigationStackState: navigationStackState, description: "Setting Navigation Stack to show alert details")
        store.dispatch(viewStackAction)
    }
    
    func buildNavigationStackState(viewControllers: [ViewController]) -> NavigationStackState {
        return NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
    }
}
