//
//  LocationReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import Foundation
import ReSwift
import CoreLocation

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
        case let action as RequestLocationResultLoaded:
            locationState = reduceRequestLocationResultLoaded(action: action, state: state)

        default:
            break
        }

        return locationState
    }

    static func reduceRequestLocation(action _: RequestLocation, state: LocationState) -> LocationState {
        return state
    }

    static func reduceRequestLocationResultLoaded(action: RequestLocationResultLoaded, state _: LocationState) -> LocationState {
        return LocationState(authorizationStatus: action.authorizationStatus, locationCoordinate: action.locationCoordinate)
    }
}
