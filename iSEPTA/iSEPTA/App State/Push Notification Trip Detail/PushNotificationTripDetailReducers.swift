//
//  PushNotificationTripDetailReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct PushNotificationTripDetailReducer {
    static func main(action: Action, state: PushNotificationTripDetailState?) -> PushNotificationTripDetailState {
        if let state = state {
            guard let action = action as? PushNotificationTripDetailAction else { return state }
            return reducePushNotificationTripDetailAction(action: action, state: state)
        } else {
            return PushNotificationTripDetailState()
        }
    }

    static func reducePushNotificationTripDetailAction(action: PushNotificationTripDetailAction, state: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        var newState = state
        switch action {
        case let action as AddPushNotificationTripDetailDelayNotification:
            newState = reduceAddPushNotificationTripDetailDelayNotification(action: action, state: state)
        case let action as UpdatePushNotificationTripDetailStatus:
            newState = reduceUpdatePushNotificationTripDetailStatus(action: action, state: state)
        case let action as UpdatePushNotificationTripDetailData:
            newState = reduceUpdatePushNotificationTripDetailData(action: action, state: state)
        case let action as ClearPushNotificationTripDetailData:
            newState = reduceClearPushNotificationTripDetailData(action: action, state: state)
        default:
            break
        }

        return newState
    }

    static func reduceAddPushNotificationTripDetailDelayNotification(action: AddPushNotificationTripDetailDelayNotification, state _: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        var newState = PushNotificationTripDetailState()
        newState.tripId = action.septaDelayNotification.vehicleId
        newState.routeId = action.septaDelayNotification.routeId
        newState.delayNotification = action.septaDelayNotification
        return newState
    }

    static func reduceUpdatePushNotificationTripDetailStatus(action: UpdatePushNotificationTripDetailStatus, state: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        var newState = state
        newState.pushNotificationTripDetailUpdateStatus = action.status
        return newState
    }

    static func reduceUpdatePushNotificationTripDetailData(action: UpdatePushNotificationTripDetailData, state: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        var newState = state
        newState.pushNotificationTripDetailData = action.pushNotificationTripDetailData
        newState.pushNotificationTripDetailUpdateStatus = .dataLoadedSuccessfully
        newState.results = action.pushNotificationTripDetailData.results ?? 0
        return newState
    }

    static func reduceClearPushNotificationTripDetailData(action: ClearPushNotificationTripDetailData, state _: PushNotificationTripDetailState) -> PushNotificationTripDetailState {
        return PushNotificationTripDetailState()
    }
}
