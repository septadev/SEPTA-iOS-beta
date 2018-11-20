//
//  AlertActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule

protocol AlertAction: SeptaAction {}

struct NewAlertsRetrieved: AlertAction {
    let alertsByTransitModeThenRoute: AlertsByTransitModeThenRoute
    let description = "New Alerts have been retrieved"
}

struct AlertTransitModeSelected: AlertAction {
    let transitMode: TransitMode
    let description = "New Alerts have been retrieved"
}

struct AlertRouteIdSelected: AlertAction {
    let routeId: String
    let description = "New Alerts have been retrieved"
}

struct AlertDetailsLoaded: AlertAction {
    let alertDetails: [AlertDetails_Alert]
    let description = "New Alerts have been retrieved"
}

struct GenericAlertDetailsLoaded: AlertAction {
    let genericAlertDetails: [AlertDetails_Alert]
    let description = "New Generic Alerts have been retrieved"
}

struct AppAlertDetailsLoaded: AlertAction {
    let appAlertDetails: [AlertDetails_Alert]
    let description = "New App Alerts have been retrieved"
}

struct ResetAlertRequest: AlertAction {
    let description = "Clear out alertRequest Info"
}

struct ResetModalAlertsDisplayed: AlertAction {
    let modalAlertsDisplayed: Bool
    let description = "Setting modal Alerts Displayed"
}

struct DoNotShowThisAlertAgain: AlertAction {
    let alertLastDisplayed: String
    let description = "Don’t Show Me This Alert Again"
}
