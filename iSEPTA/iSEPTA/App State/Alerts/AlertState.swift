//
//  SeptaAlerts.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule

typealias AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]]

struct AlertState {
    
    // transitMode/RouteId/SeptaAlert
    var alertDict: AlertsByTransitModeThenRoute
    var lastUpdated: Date
    var scheduleState: ScheduleState
    var alertDetails: [AlertDetails_Alert]
    var genericAlertDetails: [AlertDetails_Alert]
    var appAlertDetails: [AlertDetails_Alert]
    var hasGenericAlerts: Bool { return hasActiveAlerts(alertDetails: genericAlertDetails) }
    var hasAppAlerts: Bool { return hasActiveAlerts(alertDetails: appAlertDetails) }
    var hasGenericOrAppAlerts: Bool { return hasGenericAlerts || hasAppAlerts }
    var modalAlertsDisplayed: Bool
    var genericAlertWasShown: Bool
    var appAlertWasShown: Bool

    init(alertDict: AlertsByTransitModeThenRoute = [TransitMode: [String: SeptaAlert]](), scheduleState: ScheduleState = ScheduleState(), lastUpdated: Date = Date.distantPast, alertDetails: [AlertDetails_Alert] = [AlertDetails_Alert](), genericAlertDetails: [AlertDetails_Alert] = [AlertDetails_Alert](), appAlertDetails: [AlertDetails_Alert] = [AlertDetails_Alert](), modalAlertsDisplayed: Bool = false, genericAlertWasShown: Bool = false, appAlertWasShown: Bool = false) {
        self.alertDict = alertDict
        self.lastUpdated = lastUpdated
        self.scheduleState = scheduleState
        self.alertDetails = alertDetails
        self.genericAlertDetails = genericAlertDetails
        self.appAlertDetails = appAlertDetails
        self.modalAlertsDisplayed = modalAlertsDisplayed
        self.genericAlertWasShown = genericAlertWasShown
        self.appAlertWasShown = appAlertWasShown
    }

    func hasActiveAlerts(alertDetails: [AlertDetails_Alert]) -> Bool {
        let messages: [String?] = alertDetails.map { $0.message }
        return messages.filter({ !$0.isBlank }).count > 0
    }
}

extension AlertState: Equatable {}
func == (lhs: AlertState, rhs: AlertState) -> Bool {
    var areEqual = true

    areEqual = lhs.lastUpdated == rhs.lastUpdated
    guard areEqual else { return false }

    return areEqual
}
