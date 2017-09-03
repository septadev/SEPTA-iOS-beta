//
//  LocationState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation
import SeptaSchedule

struct LocationState {
    let userHasRequestedLocationState: Bool
    let authorizationStatus: CLAuthorizationStatus
    let locationCoordinate: CLLocationCoordinate2D?
    let errorMessage: String?

    init(userHasRequestedLocationState: Bool = false,
         authorizationStatus: CLAuthorizationStatus = CLAuthorizationStatus.notDetermined,
         locationCoordinate: CLLocationCoordinate2D? = nil,
         errorMessage: String? = nil) {
        self.userHasRequestedLocationState = userHasRequestedLocationState
        self.authorizationStatus = authorizationStatus
        self.locationCoordinate = locationCoordinate
        self.errorMessage = errorMessage
    }
}

extension LocationState: Equatable {}
func ==(lhs: LocationState, rhs: LocationState) -> Bool {
    var areEqual = true

    areEqual = lhs.userHasRequestedLocationState == rhs.userHasRequestedLocationState
    guard areEqual else { return false }

    areEqual = lhs.authorizationStatus == rhs.authorizationStatus
    guard areEqual else { return false }

    if let lhsCoordinate = lhs.locationCoordinate, let rhsCoordinate = rhs.locationCoordinate {
        areEqual = (lhsCoordinate.latitude == rhsCoordinate.latitude) && (lhsCoordinate.longitude == rhsCoordinate.longitude)
    } else if lhs.locationCoordinate == nil && rhs.locationCoordinate == nil {
        areEqual = true
    } else {
        areEqual = false
    }

    if let lhsMessage = lhs.errorMessage, let rhsMessage = rhs.errorMessage {
        areEqual = lhsMessage == rhsMessage
    } else if lhs.errorMessage == nil && rhs.errorMessage == nil {
        areEqual = true
    } else {
        areEqual = false
    }

    return areEqual
}
