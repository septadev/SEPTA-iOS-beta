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
    let client = SEPTAApiClient.defaultClient(url: "https://vnjb5kvq2b.execute-api.us-east-1.amazonaws.com/prod", apiKey: "7Nx754dd9G5YkpYoRLbi4aoNW9LtWllt1Jcbw9v8")
    init() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(oneMinuteTimerFired(timer:)), userInfo: nil, repeats: true)
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
        var tempResult = [QuickMap]()
        if shouldAttemptToUpdateAlerts() {
            client.getAlerts(route: "").then { alerts -> Void in
                if let alerts = alerts?.alerts {
                    for rawAlert in alerts {
                        if let mappingResult = self.mapRestAlert(alert: rawAlert) {
                            tempResult.append(mappingResult)
                        }
                    }
                    let busAlerts = tempResult.filter { $0.transitMode == .bus }
                    let railAlerts = tempResult.filter { $0.transitMode == .rail }
                    let subwayAlerts = tempResult.filter { $0.transitMode == .subway }
                    let trolleyAlerts = tempResult.filter { $0.transitMode == .trolley }
                    let nhslAlerts = tempResult.filter { $0.transitMode == .nhsl }

                    let busDictionary: [String: SeptaAlert] = busAlerts.reduce([String: SeptaAlert]()) {
                        result, quickmap in
                        var result = result
                        result[quickmap.routeId] = quickmap.septaAlert
                        return result
                    }
                }
            }.catch { err in
                print(err)
            }
        }
    }

    func mapRestAlert(alert: Alert) -> QuickMap? {
        guard
            let transitModeString = alert.mode,
            let transitMode = TransitMode.convertFromTransitMode(transitModeString),
            let routeId = alert.route_id,
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
