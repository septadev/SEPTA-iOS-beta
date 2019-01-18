//
//  AlertDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule

class AlertDetailProvider {
    static let sharedInstance = AlertDetailProvider()
    var watcher = AlertState_ScheduleState_ScheduleRequestWatcher()
    var currentRouteId = "ZZZZZ"
    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    private init() {
        watcher.delegate = self
    }

    func getDetailAlert() {
        guard let route_id = getSeptaRouteIdentifier() else { return }
        client.getAlertDetails(routeName: route_id).then { alertDetails -> Void in
            if let alertDetails = alertDetails?.alerts {
                let action = AlertDetailsLoaded(alertDetails: alertDetails)
                store.dispatch(action)
            }
        }.catch { err in
            print(err)
        }
    }

    func getSeptaRouteIdentifier() -> String? {
        let scheduleRequest = store.state.alertState.scheduleState.scheduleRequest
        guard let routeId = scheduleRequest.selectedRoute?.routeId else { return nil }
        let transitMode = getTransitModeName(transitMode: scheduleRequest.transitMode)
        let route_id = "\(transitMode)_route_\(routeId)"
        return route_id
    }
    
    func getTransitModeName(transitMode: TransitMode) -> String {
        switch transitMode.rawValue {
        case 0:
            return "bus"
        case 1,2,3:
            return "rr"
        case 4:
            return "trolley"
        default:
            return "bus"
        }
    }

}

extension AlertDetailProvider: ScheduleRequestWatcherDelegate {
    func scheduleRequestUpdated(scheduleRequest: ScheduleRequest) {
        guard let routeId = scheduleRequest.selectedRoute?.routeId else { return }
        if routeId != currentRouteId {
            getDetailAlert()
        }
    }
}
