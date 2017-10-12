//
//  TripDetailReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct TripDetailReducer {

    static func main(action: Action, state: TripDetailState?) -> TripDetailState {
        if let state = state {
            guard let action = action as? TripDetailAction else { return state }
            return reduceTripDetailAction(action: action, state: state)
        } else {
            return TripDetailState()
        }
    }

    static func reduceTripDetailAction(action: TripDetailAction, state: TripDetailState) -> TripDetailState {
        var newState = state
        switch action {
        case let action as UpdateTripDetails:
            newState = reduceUpdateSeptaConnection(action: action, state: state)
        default:
            break
        }

        return newState
    }

    static func reduceUpdateSeptaConnection(action: UpdateTripDetails, state _: TripDetailState) -> TripDetailState {
        return TripDetailState(tripDetails: action.tripDetails)
    }
}
