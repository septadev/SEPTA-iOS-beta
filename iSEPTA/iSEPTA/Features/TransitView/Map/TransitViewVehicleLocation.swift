//
//  TransitViewVehicleLocation.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/11/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit
import SeptaSchedule

struct TransitViewVehicleLocation {
    let coordinate: CLLocationCoordinate2D
    let mode: TransitMode
    let routeId: String
}

extension TransitViewVehicleLocation: Equatable {}
func == (lhs: TransitViewVehicleLocation, rhs: TransitViewVehicleLocation) -> Bool {
    return (lhs.routeId == rhs.routeId) &&
        (lhs.coordinate == rhs.coordinate)
}
