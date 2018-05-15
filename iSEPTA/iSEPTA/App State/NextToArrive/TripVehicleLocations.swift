//
//  VehicleLocation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation
import SeptaSchedule

struct TripVehicleLocations {
    let firstLegLocation: VehicleLocation?
    let secondLegLocation: VehicleLocation?

    init(firstLegLocation: VehicleLocation? = nil, secondLegLocation: VehicleLocation? = nil) {
        self.firstLegLocation = firstLegLocation
        self.secondLegLocation = secondLegLocation
    }
}

extension TripVehicleLocations: Equatable {}
func == (lhs: TripVehicleLocations, rhs: TripVehicleLocations) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.firstLegLocation, newValue: rhs.firstLegLocation).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.secondLegLocation, newValue: rhs.secondLegLocation).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
