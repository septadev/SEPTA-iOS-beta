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
            switch action {
            case let action as ScheduleAction where action.targetForScheduleAction.includesMe(.alerts) :
                return reduceScheduleAction(action: action, state: state)
            case let action as AlertAction:
                return reduceAlertActions(action: action, state: state)
            default:
                return state
            }

        } else {
            return AlertState()
        }
    }

    static func reduceScheduleAction(action: ScheduleAction, state: AlertState) -> AlertState {
        let scheduleState = ScheduleReducer.main(action: action, state: state.scheduleState)
        return AlertState(alertDict: state.alertDict, scheduleState: scheduleState, lastUpdated: state.lastUpdated, alertDetails: state.alertDetails)
    }

    static func reduceAlertActions(action: AlertAction, state: AlertState) -> AlertState {
        var newState = state
        switch action {
        case let action as NewAlertsRetrieved:
            newState = reduceNewAlertsRetrieved(action: action, state: state)
        case let action as AlertDetailsLoaded:
            newState = reduceAlertDetailsLoaded(action: action, state: state)
        default:
            break
        }

        return newState
    }

    static func reduceNewAlertsRetrieved(action: NewAlertsRetrieved, state: AlertState) -> AlertState {
        return AlertState(alertDict: action.alertsByTransitModeThenRoute, scheduleState: state.scheduleState, lastUpdated: Date(), alertDetails: state.alertDetails, genericAlertDetails: state.genericAlertDetails)
    }

    static func reduceAlertDetailsLoaded(action: AlertDetailsLoaded, state: AlertState) -> AlertState {

        return AlertState(alertDict: state.alertDict, scheduleState: state.scheduleState, lastUpdated: state.lastUpdated, alertDetails: action.alertDetails, genericAlertDetails: state.genericAlertDetails)
    }

    static func reduceGenericAlertDetailsLoaded(action: GenericAlertDetailsLoaded, state: AlertState) -> AlertState {

        return AlertState(alertDict: state.alertDict, scheduleState: state.scheduleState, lastUpdated: state.lastUpdated, alertDetails: state.alertDetails, genericAlertDetails: action.genericAlertDetails)
    }
}
