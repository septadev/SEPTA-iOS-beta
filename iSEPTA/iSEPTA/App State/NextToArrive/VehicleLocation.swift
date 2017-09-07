//
//  VehicleLocation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation

struct VehicleLocation {
    let firstLegLocation: CLLocationCoordinate2D
    let secondLegLocation: CLLocationCoordinate2D

    init(firstLegLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(), secondLegLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
        self.firstLegLocation = firstLegLocation
        self.secondLegLocation = secondLegLocation
    }
}

extension VehicleLocation: Equatable {}
func ==(lhs: VehicleLocation, rhs: VehicleLocation) -> Bool {
    var areEqual = true

    areEqual = lhs.firstLegLocation == rhs.firstLegLocation
    guard areEqual else { return false }

    areEqual = lhs.secondLegLocation == rhs.secondLegLocation
    guard areEqual else { return false }

    return areEqual
}
