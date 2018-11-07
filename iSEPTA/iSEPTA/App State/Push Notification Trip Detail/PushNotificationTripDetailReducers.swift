//
//  PushNotificationTripDetailReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct TripDetailReducer {
    static func main(action: Action, state: Tri?) -> PushNotificationTripDetailState {
        if let state = state {
            guard let action = action as? PushNotificationTripDetailAction else { return state }
            return reduceTripDetailAction(action: action, state: state)
        } else {
            return PushNotificationTripDetailState()
        }
    }

    static func reduceTripDetailAction(action: PushNotificationTripDetailAction, state: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        var newState = state
        switch action {
        case let action as UpdatePushNotificationTripDetail:
            newState = reduceUpdateTripDetails(action: action, state: state)
        case let action as ClearPushNotificationTripDetail:
            newState = reduceClearTripDetails(action: action, state: state)
        default:
            break
        }

        return newState
    }

    static func reduceUpdateTripDetails(action: UpdatePushNotificationTripDetail, state _: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        return  PushNotificationTripDetailState()
    }

    static func reduceClearTripDetails(action: ClearPushNotificationTripDetail, state _: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        return PushNotificationTripDetailState()
    }
}
