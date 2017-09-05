//
//  StopWithDistance.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import CoreLocation

struct StopWithDistance {
    let stop: Stop
    let distanceString: String
    let distanceMeasurement: CLLocationDistance

    init(stop: Stop, distanceMeasurement: CLLocationDistance, distanceString: String) {
        self.stop = stop
        self.distanceMeasurement = distanceMeasurement
        self.distanceString = distanceString
    }
}
