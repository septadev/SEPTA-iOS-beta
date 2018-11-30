//
//  AlertReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaRest

struct AlertReducer {
    static func main(action: Action,
                     state: AlertState?) -> AlertState {
        if let state = state {
            switch action {
            case let action as ScheduleAction where action.targetForScheduleAction.includesMe(.alerts):
                return reduceScheduleAction(action: action,
                                            state: state)
            case let action as AlertAction:
                return reduceAlertActions(action: action,
                                          state: state)
            default:
                return state
            }

        } else {
            return AlertState()
        }
    }

    static func reduceScheduleAction(action: ScheduleAction,
                                     state: AlertState) -> AlertState {
        let scheduleState = ScheduleReducer.main(action: action,
                                                 state: state.scheduleState)
        return AlertState(alertDict: state.alertDict,
                          scheduleState: scheduleState,
                          lastUpdated: state.lastUpdated,
                          alertDetails: state.alertDetails,
                          genericAlertDetails: state.genericAlertDetails,
                          appAlertDetails: state.appAlertDetails,
                          modalAlertsDisplayed: state.modalAlertsDisplayed,
                          genericAlertWasShown: state.genericAlertWasShown,
                          appAlertWasShown: state.appAlertWasShown)
    }

    static func reduceAlertActions(action: AlertAction,
                                   state: AlertState) -> AlertState {
        var newState = state
        switch action {
        case let action as NewAlertsRetrieved:
            newState = reduceNewAlertsRetrieved(action: action,
                                                state: state)
        case let action as AlertDetailsLoaded:
            newState = reduceAlertDetailsLoaded(action: action,
                                                state: state)
        case let action as GenericAlertDetailsLoaded:
            newState = reduceGenericAlertDetailsLoaded(action: action,
                                                       state: state)
        case let action as AppAlertDetailsLoaded:
            newState = reduceAppAlertDetailsLoaded(action: action,
                                                   state: state)
        case let action as ResetModalAlertsDisplayed:
            newState = reduceResetModalAlertsDisplayed(action: action,
                                                       state: state)
        case let action as ResetGenericAlertWasShown:
            newState = reduceResetGenericAlertWasShown(action: action,
                                                        state: state)
        case let action as ResetAppAlertWasShown:
            newState = reduceResetAppAlertWasShown(action: action,
                                                    state: state)
        default:
            break
        }

        return newState
    }

    static func reduceNewAlertsRetrieved(action: NewAlertsRetrieved,
                                         state: AlertState) -> AlertState {
        var newState = state
        newState.alertDict = action.alertsByTransitModeThenRoute
        newState.lastUpdated = Date()
        
        return newState
    }

    static func reduceAlertDetailsLoaded(action: AlertDetailsLoaded,
                                         state: AlertState) -> AlertState {
        var newState = state
        newState.alertDetails = action.alertDetails
        newState.lastUpdated = Date()
        
        return newState
    }

    static func reduceGenericAlertDetailsLoaded(action: GenericAlertDetailsLoaded,
                                                state: AlertState) -> AlertState {
        var newState = state
        newState.genericAlertDetails = action.genericAlertDetails
        newState.lastUpdated = Date()
        
        return newState
    }

    static func reduceAppAlertDetailsLoaded(action: AppAlertDetailsLoaded,
                                            state: AlertState) -> AlertState {
        var newState = state
        newState.appAlertDetails = action.appAlertDetails
        newState.lastUpdated = Date()
        
        return newState
    }

    static func reduceResetModalAlertsDisplayed(action: ResetModalAlertsDisplayed,
                                                state: AlertState) -> AlertState {
        var newState = state
        newState.modalAlertsDisplayed = action.modalAlertsDisplayed
        newState.lastUpdated = Date()
        
        return newState
    }

    static func reduceResetGenericAlertWasShown(action: ResetGenericAlertWasShown,
                                                 state: AlertState) -> AlertState {
        var newState = state
        newState.genericAlertWasShown = action.genericAlertWasShown
        newState.lastUpdated = Date()

        return newState
    }

    static func reduceResetAppAlertWasShown(action: ResetAppAlertWasShown,
                                             state: AlertState) -> AlertState {
        var newState = state
        newState.appAlertWasShown = action.appAlertWasShown
        newState.lastUpdated = Date()
        
        return newState
    }

}
