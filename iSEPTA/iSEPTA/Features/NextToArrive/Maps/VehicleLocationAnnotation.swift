//
//  VehicleLocationAnnotation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/9/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import MapKit

class VehicleLocationAnnotation: MKPointAnnotation {
    let vehicleLocation: VehicleLocation
    init(vehicleLocation: VehicleLocation) {
        self.vehicleLocation = vehicleLocation
    }
}
