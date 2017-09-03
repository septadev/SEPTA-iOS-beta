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

struct RequestLocationResultLoaded: LocationAction {
    let authorizationStatus: CLAuthorizationStatus
    let locationCoordinate: CLLocationCoordinate2D?
    let description = "Location info returned from LocationManager"
}
