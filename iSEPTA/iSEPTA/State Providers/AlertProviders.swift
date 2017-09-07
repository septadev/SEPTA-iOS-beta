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
        var quickMap = [QuickMap]()
        if shouldAttemptToUpdateAlerts() {
            client.getAlerts(route: "").then { alerts -> Void in
                if let alerts = alerts?.alerts {
                    for rawAlert in alerts {
                        if let mappingResult = self.mapRestAlert(alert: rawAlert) {
                            quickMap.append(mappingResult)
                        }
                    }
                    var alertsByTransitModeThenRoute = AlertsByTransitModeThenRoute()
                    alertsByTransitModeThenRoute[.bus] = self.mapToTransitMode(.bus, quickMap: quickMap)
                    alertsByTransitModeThenRoute[.rail] = self.mapToTransitMode(.rail, quickMap: quickMap)
                    alertsByTransitModeThenRoute[.subway] = self.mapToTransitMode(.subway, quickMap: quickMap)
                    alertsByTransitModeThenRoute[.trolley] = self.mapToTransitMode(.trolley, quickMap: quickMap)
                    alertsByTransitModeThenRoute[.nhsl] = self.mapToTransitMode(.nhsl, quickMap: quickMap)

                    let action = NewAlertsRetrieved(alertsByTransitModeThenRoute: alertsByTransitModeThenRoute)
                    store.dispatch(action)
                }
            }.catch { err in
                print(err)
            }
        }
    }

    func mapToTransitMode(_ transitMode: TransitMode, quickMap: [QuickMap]) -> [String: SeptaAlert] {
        let filteredAlerts = quickMap.filter { $0.transitMode == transitMode }
        let result: [String: SeptaAlert] = filteredAlerts.reduce([String: SeptaAlert]()) {
            result, quickmap in
            var result = result
            result[quickmap.routeId] = quickmap.septaAlert
            return result
        }
        return result
    }

    func mapRestAlert(alert: Alert) -> QuickMap? {
        guard
            let transitModeString = alert.mode,
            let transitMode = TransitMode.convertFromTransitMode(transitModeString),
            let routeId = alert.route_name,
            let advisory = alert.advisory,
            let weather = alert.snow,
            let detour = alert.detour,
            let alert = alert.alert else { return nil }
        return QuickMap(transitMode: transitMode, routeId: routeId, septaAlert: SeptaAlert(advisory: advisory, alert: alert, detour: detour, weather: weather))
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
