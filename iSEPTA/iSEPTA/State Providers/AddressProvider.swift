//
//  AddressProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import CoreLocation

class AddressLookupProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = AddressLookupState
    let geoCoder = CLGeocoder()
    static let sharedInstance = AddressLookupProvider()
    private init() {
        identifyPhillyRegion()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.addressLookupState
            }.skipRepeats { $0 == $1 }
        }
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    var region: CLRegion?

    func identifyPhillyRegion() {
        // Get a region in Philly to optimize searches
        let location = CLLocation(latitude: 39.936770, longitude: -75.228173)
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let firstPlacemark = placemarks?.first else { return }
            self.region = firstPlacemark.region
        }
    }

    let currentState = ""
    func newState(state: StoreSubscriberStateType) {
        if shouldLookupByString(state: state) {
            lookupAddressForString(searchString: state.searchString)
        } else if shouldLookupByCoordinates(state: state) {
            lookupAddressForCoordinates(coordinates: state.searchLocationCoordinate)
        }
    }

    func shouldLookupByString(state: AddressLookupState) -> Bool {
        return state.addressLookupSearchMode == .byString && state.searchString.count > 3
    }

    func shouldLookupByCoordinates(state: AddressLookupState) -> Bool {
        return state.addressLookupSearchMode == .byCoordinates
    }

    func lookupAddressForString(searchString: String) {
        geoCoder.geocodeAddressString(searchString, in: region) { placemarks, error in
            let placemarks = placemarks ?? [CLPlacemark]()
            let action = LoadLookupAddresses(searchResults: placemarks, error: error)
            store.dispatch(action)
        }
    }

    func lookupAddressForCoordinates(coordinates: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            let placemarks = placemarks ?? [CLPlacemark]()
            let action = LoadLookupAddresses(searchResults: placemarks, error: error)
            store.dispatch(action)
        }
    }
}
