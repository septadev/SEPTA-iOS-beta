//
//  AlertActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol AlertAction: SeptaAction {}

struct NewAlertsRetrieved: AlertAction {
    let alertsByTransitModeThenRoute: AlertsByTransitModeThenRoute
    let description = "New Alerts have been retrieved"
}
