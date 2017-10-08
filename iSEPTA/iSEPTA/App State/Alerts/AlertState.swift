//
//  SeptaAlerts.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import SeptaRest

typealias AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]]

struct AlertState {
    // transitMode/RouteId/SeptaAlert
    let alertDict: AlertsByTransitModeThenRoute
    let lastUpdated: Date
    let scheduleState: ScheduleState
    let alertDetails: [AlertDetails_Alert]
    let genericAlertDetails: [AlertDetails_Alert]
    var hasGenericAlerts: Bool { return AlertDetailsViewModel.hasGenericMessage(alertDetails: genericAlertDetails) }

    init(alertDict: AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]](), scheduleState: ScheduleState = ScheduleState(), lastUpdated: Date = Date.distantPast, alertDetails: [AlertDetails_Alert] = [AlertDetails_Alert](), genericAlertDetails: [AlertDetails_Alert] = [AlertDetails_Alert]()) {
        self.alertDict = alertDict
        self.lastUpdated = lastUpdated
        self.scheduleState = scheduleState
        self.alertDetails = alertDetails
        self.genericAlertDetails = genericAlertDetails
    }
}

extension AlertState: Equatable {}
func ==(lhs: AlertState, rhs: AlertState) -> Bool {
    var areEqual = true

    areEqual = lhs.lastUpdated == rhs.lastUpdated
    guard areEqual else { return false }

    return areEqual
}
