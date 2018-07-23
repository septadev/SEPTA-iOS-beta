//
//  LocationReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation
import ReSwift

struct LocationReducer {
    static func main(action: Action, state: LocationState?) -> LocationState {
        if let state = state {
            guard let action = action as? LocationAction else { return state }
            return reduceLocationAction(action: action, state: state)
        } else {
            return LocationState()
        }
    }

    static func reduceLocationAction(action: LocationAction, state: LocationState) -> LocationState {
        var locationState = state
        switch action {
        case let action as RequestLocation:
            locationState = reduceRequestLocation(action: action, state: state)
        case let action as LocationAuthorizationChanged:
            locationState = reduceLocationAuthorizationChanged(action: action, state: state)
        case let action as RequestLocationResultFailed:
            locationState = reduceRequestLocationResultFailed(action: action, state: state)
        case let action as RequestLocationResultSucceeded:
            locationState = reduceRequestLocationResultSucceeded(action: action, state: state)
        default:
            break
        }

        return locationState
    }

    static func reduceRequestLocation(action _: RequestLocation, state: LocationState) -> LocationState {
        return LocationState(userHasRequestedLocationState: true, authorizationStatus: state.authorizationStatus, locationCoordinate: state.locationCoordinate)
    }

    static func reduceLocationAuthorizationChanged(action: LocationAuthorizationChanged, state: LocationState) -> LocationState {
        return LocationState(
            userHasRequestedLocationState: state.userHasRequestedLocationState,
            authorizationStatus: action.authorizationStatus,
            locationCoordinate: state.locationCoordinate,
            errorMessage: state.errorMessage
        )
    }

    static func reduceRequestLocationResultFailed(action: RequestLocationResultFailed, state: LocationState) -> LocationState {
        return LocationState(
            userHasRequestedLocationState: false,
            authorizationStatus: state.authorizationStatus,
            locationCoordinate: nil,
            errorMessage: action.errorMessage
        )
    }

    static func reduceRequestLocationResultSucceeded(action: RequestLocationResultSucceeded, state: LocationState) -> LocationState {
        return LocationState(
            userHasRequestedLocationState: false,
            authorizationStatus: state.authorizationStatus,
            locationCoordinate: action.locationCoordinate,
            errorMessage: nil
        )
    }
}
