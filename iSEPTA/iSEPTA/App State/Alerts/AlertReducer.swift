//
//  AlertReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct AlertReducer {

    static func main(action: Action, state: AlertState?) -> AlertState {
        if let state = state {
            guard let action = action as? AlertAction else { return state }
            return reduceAlertActions(action: action, state: state)
        } else {
            return AlertState()
        }
    }

    static func reduceAlertActions(action: AlertAction, state: AlertState) -> AlertState {
        var newPref = state
        switch action {
        case let action as NewAlertsRetrieved:
            newPref = reduceNewAlertsRetrieved(action: action, state: state)
        default:
            break
        }

        return newPref
    }

    static func reduceNewAlertsRetrieved(action: NewAlertsRetrieved, state _: AlertState) -> AlertState {
        return AlertState(alertDict: action.alertsByTransitModeThenRoute, lastUpdated: Date())
    }
}
