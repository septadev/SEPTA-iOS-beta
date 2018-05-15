//
//  FavoritesMiddlewareActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
protocol TripDetailMiddlewareAction: SeptaAction {}

struct ShowTripDetails: TripDetailMiddlewareAction {
    let nextToArriveStop: NextToArriveStop
    let description = "Show Trip Details for a particular stop"
}
