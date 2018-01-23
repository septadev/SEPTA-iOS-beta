//
//  AddressLookup.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation

struct AddressLookupState {
    let addressLookupSearchMode: AddressLookupSearchMode
    let searchString: String
    let searchLocationCoordinate: CLLocationCoordinate2D
    let searchResults: [CLPlacemark]
    let error: Error?
    init(addressLookupSearchMode: AddressLookupSearchMode = .none,
         searchString: String = "",
         searchLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(),
         searchResults: [CLPlacemark] = [CLPlacemark](),
         error: Error? = nil) {
        self.addressLookupSearchMode = addressLookupSearchMode
        self.searchString = searchString
        self.searchLocationCoordinate = searchLocationCoordinate
        self.searchResults = searchResults
        self.error = error
    }
}

extension AddressLookupState: Equatable {}
func == (lhs: AddressLookupState, rhs: AddressLookupState) -> Bool {
    var areEqual = true

    areEqual = lhs.addressLookupSearchMode == rhs.addressLookupSearchMode
    guard areEqual else { return false }

    areEqual = lhs.searchString == rhs.searchString
    guard areEqual else { return false }

    areEqual = lhs.searchResults == rhs.searchResults
    guard areEqual else { return false }

    return areEqual
}
