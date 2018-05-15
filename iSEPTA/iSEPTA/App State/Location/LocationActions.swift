//
//  LocationActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationAction: SeptaAction {}

struct RequestLocation: LocationAction {
    let description: String = "User has requested his location to be used in the app"
}

struct LocationAuthorizationChanged: LocationAction {
    let authorizationStatus: CLAuthorizationStatus
    let description: String = "Access to location data has changed"
}

struct RequestLocationResultFailed: LocationAction {
    let errorMessage: String
    let description = "Location info returned error from LocationManager"
}

struct RequestLocationResultSucceeded: LocationAction {
    let locationCoordinate: CLLocationCoordinate2D
    let description = "Location info returned successfrom LocationManager"
}
