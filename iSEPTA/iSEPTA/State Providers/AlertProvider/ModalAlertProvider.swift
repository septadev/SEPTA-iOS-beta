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

class ModalAlertProvider {
    static let sharedInstance = ModalAlertProvider()
    let calendar = Calendar.current
    var timer: Timer?

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)
    private init() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(oneMinuteTimerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func oneMinuteTimerFired(timer _: Timer) {
    }

    struct QuickMap {
        let transitMode: TransitMode
        let routeId: String
        let septaAlert: SeptaAlert
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
            let alert = alert.alert else { return nil }
        return SeptaAlert(advisory: advisory, alert: alert, detour: detour, weather: weather)
    }

    func stripTimeComponentFromDate(date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let strippedDate = Calendar.current.date(from: components) {
            return strippedDate
        } else {
            return Date.distantPast
        }
    }

    deinit {
        timer?.invalidate()
    }
}
