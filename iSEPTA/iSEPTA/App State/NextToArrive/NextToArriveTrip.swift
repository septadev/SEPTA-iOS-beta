//
//  NextToArriveTrip.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation

struct NextToArriveTrip {
    let startStop: NextToArriveStop
    let endStop: NextToArriveStop
    let vehicleLocation: TripVehicleLocations
    let connectionLocation: NextToArriveConnectionStation?

    init(startStop: NextToArriveStop, endStop: NextToArriveStop, vehicleLocation: TripVehicleLocations, connectionLocation: NextToArriveConnectionStation?) {
        self.startStop = startStop
        self.endStop = endStop
        self.vehicleLocation = vehicleLocation
        self.connectionLocation = connectionLocation
    }
}

extension NextToArriveTrip: Equatable {}
func == (lhs: NextToArriveTrip, rhs: NextToArriveTrip) -> Bool {
    var areEqual = true

    areEqual = lhs.startStop == rhs.startStop
    guard areEqual else { return false }

    areEqual = lhs.endStop == rhs.endStop
    guard areEqual else { return false }

    areEqual = lhs.vehicleLocation == rhs.vehicleLocation
    guard areEqual else { return false }

    return areEqual
}
