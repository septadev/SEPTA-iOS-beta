//
//  AlertActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import SeptaRest

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
    let description = "New Alerts have been retrieved"
}

struct ResetAlertRequest: AlertAction {
    let description = "Clear out alertRequest Info"
}
