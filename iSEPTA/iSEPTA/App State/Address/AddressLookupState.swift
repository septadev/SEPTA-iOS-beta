//
//  AddressLookup.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation

struct AddressLookupState {
    let searchString: String
    let searchResults: [CLPlacemark]
    let error: Error?
    init(searchString: String = "", searchResults: [CLPlacemark] = [CLPlacemark](), error: Error? = nil) {
        self.searchString = searchString
        self.searchResults = searchResults
        self.error = error
    }
}

extension AddressLookupState: Equatable {}
func ==(lhs: AddressLookupState, rhs: AddressLookupState) -> Bool {
    var areEqual = true

    areEqual = lhs.searchString == rhs.searchString
    guard areEqual else { return false }

    areEqual = lhs.searchResults == rhs.searchResults
    guard areEqual else { return false }

    return areEqual
}
