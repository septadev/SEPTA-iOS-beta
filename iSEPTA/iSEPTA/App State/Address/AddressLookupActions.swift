//
//  AddressLookupActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation

protocol AddressLookupAction: SeptaAction {}

struct LookupAddressRequest: AddressLookupAction {
    let searchString: String
    let description = "User entered an address to search by"
}

struct LookupAddressRequestCoordinates: AddressLookupAction {
    let location: CLLocation
    let description = "User entered an address to search by"
}

struct LoadLookupAddresses: AddressLookupAction {
    let searchResults: [CLPlacemark]
    let error: Error?
    let description = "The Geocoder returned these addresses"
}

struct ClearLookupAddresses: AddressLookupAction {
    let description = "Clear out the address that have been retrieved"
}
