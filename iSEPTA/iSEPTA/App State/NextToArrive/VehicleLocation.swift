//
//  VehicleLocation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation
import SeptaSchedule

struct VehicleLocation {
    let firstLegLocation: CLLocationCoordinate2D?
    let secondLegLocation: CLLocationCoordinate2D?

    init(firstLegLocation: CLLocationCoordinate2D? = nil, secondLegLocation: CLLocationCoordinate2D? = nil) {
        self.firstLegLocation = firstLegLocation
        self.secondLegLocation = secondLegLocation
    }
}

extension VehicleLocation: Equatable {}
func ==(lhs: VehicleLocation, rhs: VehicleLocation) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.firstLegLocation, newValue: rhs.firstLegLocation).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.secondLegLocation, newValue: rhs.secondLegLocation).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
