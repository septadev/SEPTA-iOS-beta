//
//  NextToArriveTrip.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation

struct NextToArriveTrip {
    let startStop: NextToArriveStop
    let endStop: NextToArriveStop
    let vehicleLocation: VehicleLocation
    let connectionLocation: NextToArriveConnectionStation
    let arrivalTime: Date

    init(startStop: NextToArriveStop, endStop: NextToArriveStop, vehicleLocation: VehicleLocation, arrivalTime: Date, connectionLocation: NextToArriveConnectionStation) {
        self.startStop = startStop
        self.endStop = endStop
        self.vehicleLocation = vehicleLocation
        self.arrivalTime = arrivalTime
        self.connectionLocation = connectionLocation
    }
}

extension NextToArriveTrip: Equatable {}
func ==(lhs: NextToArriveTrip, rhs: NextToArriveTrip) -> Bool {
    var areEqual = true

    areEqual = lhs.startStop == rhs.startStop
    guard areEqual else { return false }

    areEqual = lhs.endStop == rhs.endStop
    guard areEqual else { return false }

    areEqual = lhs.vehicleLocation == rhs.vehicleLocation
    guard areEqual else { return false }

    areEqual = lhs.arrivalTime == rhs.arrivalTime
    guard areEqual else { return false }

    return areEqual
}
