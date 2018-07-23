//
//  VehicleLocation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation
import SeptaSchedule

struct VehicleLocation {
    let location: CLLocationCoordinate2D?
    let nextToArriveStop: NextToArriveStop
    var lastLocation: CLLocationCoordinate2D? {
        didSet {
        }
    }

    var bearing: Double?

    var distanceCovered: Double?

    var isMoving: Bool {
        guard let distanceCovered = distanceCovered else { return false }
        return distanceCovered > 50
    }

    func setBearing(location: CLLocationCoordinate2D, lastLocation: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }

        let lat1 = degreesToRadians(lastLocation.latitude)
        let lon1 = degreesToRadians(lastLocation.longitude)

        let lat2 = degreesToRadians(location.latitude)
        let lon2 = degreesToRadians(location.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansBearing
    }

    func calculateDistanceCovered(location: CLLocationCoordinate2D, lastLocation: CLLocationCoordinate2D) -> Double {
        let currentCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let lastCLLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        return currentCLLocation.distance(from: lastCLLocation)
    }

    init(location: CLLocationCoordinate2D?, lastLocation: CLLocationCoordinate2D? = nil, nextToArriveStop: NextToArriveStop) {
        self.location = location
        self.lastLocation = lastLocation
        self.nextToArriveStop = nextToArriveStop
        if let location = location, let lastLocation = lastLocation {
            bearing = setBearing(location: location, lastLocation: lastLocation)
            distanceCovered = calculateDistanceCovered(location: location, lastLocation: lastLocation)
        }
    }
}

extension VehicleLocation: Equatable {}
func == (lhs: VehicleLocation, rhs: VehicleLocation) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.location, newValue: rhs.location).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.lastLocation, newValue: rhs.lastLocation).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
