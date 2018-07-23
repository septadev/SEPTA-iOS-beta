//
//  CLLocationCoordinate2D+Equatable.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D: Equatable {}

extension CLLocationCoordinate2D {
    func isEmpty() -> Bool {
        return self == CLLocationCoordinate2D()
    }
}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    var areEqual = true

    areEqual = lhs.latitude == rhs.latitude
    guard areEqual else { return false }

    areEqual = lhs.longitude == rhs.longitude
    guard areEqual else { return false }

    return areEqual
}
