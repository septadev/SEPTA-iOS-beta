//
//  SeptaAlerts.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

typealias AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]]

struct AlertState {
    // transitMode/RouteId/SeptaAlert
    let alertDict: AlertsByTransitModeThenRoute
    let lastUpdated: Date

    init(alertDict: AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]](), lastUpdated: Date = Date.distantPast) {
        self.alertDict = alertDict
        self.lastUpdated = lastUpdated
    }
}

extension AlertState: Equatable {}
func ==(lhs: AlertState, rhs: AlertState) -> Bool {
    var areEqual = true

    areEqual = lhs.lastUpdated == rhs.lastUpdated
    guard areEqual else { return false }

    return areEqual
}
