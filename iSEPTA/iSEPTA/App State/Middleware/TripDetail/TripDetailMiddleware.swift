//
//  FavoritesMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

let tripDetailMiddleware: Middleware<AppState> = { _, _ in { next in
    return { action in
        if let action = action as? SeptaAction {
            if let action = action as? TripDetailMiddlewareAction {
                TripDetailMiddleware.generateActions(action: action)
            }
        }
        return next(action)
    }
}
}

class TripDetailMiddleware {
    static func generateActions(action: TripDetailMiddlewareAction) {
        switch action {
        case let action as ShowTripDetails:
            generateActionsToShowTripDetails(action: action)

        default:
            break
        }
    }

    static func generateActionsToShowTripDetails(action: ShowTripDetails) {
        let action = UpdateTripDetails(tripDetails: action.nextToArriveStop)
        store.dispatch(action)
        let pushAction = PushViewController(viewController: .tripDetailViewController, description: "Pushing Trip Detail View Controller")
        store.dispatch(pushAction)
    }
}
