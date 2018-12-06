//
//  AlertQueueReducer.swift
//  iSEPTA
//
//  Created by James Johnson on 12/06/2018.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct AlertQueueReducer {
    static func main(action: Action, state: AlertQueueState?) -> AlertQueueState {
        if let state = state {
            guard let action = action as? AlertQueueAction else { return state }
            
            return reduceAlertQueueActions(action: action, state: state)
            
        } else {
            return AlertQueueState()
        }
    }

    static func reduceAlertQueueActions(action: AlertQueueAction, state: AlertQueueState) -> AlertQueueState {
        var alertQueueState = state
        switch action {
        case let action as AddAlertToDisplay:
            alertQueueState = reduceAddAlertToDisplay(action: action, state: state)
        case let action as CurrentAlertDismissed:
            alertQueueState = reduceCurrentAlertDismissed(action: action, state: state)
        default:
            break
        }
        
        return alertQueueState
    }

    static func reduceAddAlertToDisplay(action: AddAlertToDisplay, state: AlertQueueState) -> AlertQueueState {
        var newState = state
        var newAlerts = state.alertsToDisplay
        newAlerts.append(action.appAlert)
        newState.alertsToDisplay = newAlerts
        return newState
    }
    
    static func reduceCurrentAlertDismissed(action: CurrentAlertDismissed, state: AlertQueueState) -> AlertQueueState {
        guard state.alertsToDisplay.count > 0 else { return state }
        var newState = state
        var newAlerts = state.alertsToDisplay
        newAlerts.removeFirst()
        newState.alertsToDisplay = newAlerts
        return newState
    }

}
