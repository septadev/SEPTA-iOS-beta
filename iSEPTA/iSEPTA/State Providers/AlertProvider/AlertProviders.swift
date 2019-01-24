//
//  AlertProviders.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule

class AlertProvider {
    static let sharedInstance = AlertProvider()
    let calendar = Calendar.current
    var timer: Timer?

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)
    private init() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(oneMinuteTimerFired(timer:)), userInfo: nil, repeats: true)
        updateAlertsIfNeeded()
    }

    @objc func oneMinuteTimerFired(timer _: Timer) {
        updateAlertsIfNeeded()
    }

    struct QuickMap {
        let transitMode: TransitMode
        let routeId: String
        let septaAlert: SeptaAlert
    }

    func updateAlertsIfNeeded() {
        var alertsByTransitModeThenRoute = makeNewAlertsByTransitModeThenRoute()

        let mapper = MapFromAlerts.sharedInstance
        if shouldAttemptToUpdateAlerts() {
            client.getAlerts(route: "").then { alerts -> Void in
                if let alerts = alerts?.alerts {
                    for rawAlert in alerts {
                        if let septaAlert = self.mapRestAlert(alert: rawAlert),
                            let quickMaps = mapper.mapAlert(mappableAlert: rawAlert) {
                            for quickMap in quickMaps {
                                alertsByTransitModeThenRoute[quickMap.transitMode]?[quickMap.routeId] = septaAlert
                            }
                        }
                    }

                    let action = NewAlertsRetrieved(alertsByTransitModeThenRoute: alertsByTransitModeThenRoute)
                    store.dispatch(action)
                }
            }.catch { err in
                print(err)
            }
        }
    }

    func makeNewAlertsByTransitModeThenRoute() -> AlertsByTransitModeThenRoute {
        var alertsByTransitModeThenRoute = AlertsByTransitModeThenRoute()
        for transitMode in TransitMode.displayOrder() {
            alertsByTransitModeThenRoute[transitMode] = [String: SeptaAlert]()
        }
        return alertsByTransitModeThenRoute
    }

    func mapRestAlert(alert: Alert) -> SeptaAlert? {
        guard
            let advisory = alert.advisory,
            let weather = alert.snow,
            let detour = alert.detour,
            let suspended = alert.suspended,
            let alert = alert.alert else { return nil }
        //if suspended {
        print("advisory: \(advisory)")
        print("detour: \(detour)")
        print("suspended: \(suspended)")
        print("=================")
        //}
        return SeptaAlert(advisory: advisory, alert: alert, detour: detour, weather: weather, suspended: suspended)
    }

    func shouldAttemptToUpdateAlerts() -> Bool {
        let lastUpdate: Date = store.state.alertState.lastUpdated

        guard let minutes = calendar.dateComponents([.minute], from: lastUpdate, to: Date()).minute else { return false }
        return minutes > 30
    }

    deinit {
        timer?.invalidate()
    }
}
