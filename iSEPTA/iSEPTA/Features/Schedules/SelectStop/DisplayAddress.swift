//
//  DisplayAddress.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation

struct DisplayAddress {
    let street: String
    let csz: String
    let placemark: CLPlacemark

    init(street: String, csz: String, placemark: CLPlacemark) {
        self.street = street
        self.csz = csz
        self.placemark = placemark
    }
}

extension DisplayAddress: Equatable {}
func == (lhs: DisplayAddress, rhs: DisplayAddress) -> Bool {
    var areEqual = true

    areEqual = lhs.street == rhs.street
    guard areEqual else { return false }

    areEqual = lhs.csz == rhs.csz
    guard areEqual else { return false }

    areEqual = lhs.placemark == rhs.placemark
    guard areEqual else { return false }

    return areEqual
}
