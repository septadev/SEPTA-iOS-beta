//
//  TransitViewVehicleAnnotation.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/11/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit
import SeptaSchedule

class TransitViewVehicleAnnotation: MKPointAnnotation {
    let annotationId = "transitViewAnnotation"

    let location: TransitViewVehicleLocation

    init(location: TransitViewVehicleLocation) {
        self.location = location
    }
}
