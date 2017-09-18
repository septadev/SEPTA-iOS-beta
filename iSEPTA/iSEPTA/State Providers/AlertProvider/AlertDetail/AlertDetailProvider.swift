//
//  AlertDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

class AlertDetailProvider {

    static let sharedInstance = AlertDetailProvider()
    var watcher = AlertState_ScheduleState_ScheduleRequest_SelectedRouteExistsWatcher()

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
        let transitMode = scheduleRequest.transitMode
        let route_id = MapToAlerts.sharedInstance.alertRouteId(forTransitMode: transitMode, dbRouteId: routeId)
        return route_id
    }
}

extension AlertDetailProvider: AlertState_ScheduleState_ScheduleRequest_SelectedRouteExistsWatcherDelegate {
    func alertState_ScheduleState_ScheduleRequest_SelectedRouteExistsUpdated(bool: Bool) {
        let routeExists = bool
        if routeExists {
            getDetailAlert()
        }
    }
}
