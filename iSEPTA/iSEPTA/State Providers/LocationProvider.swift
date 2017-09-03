//
//  LocationProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import CoreLocation
import ReSwift

class LocationProvider: NSObject, StoreSubscriber, CLLocationManagerDelegate {

    typealias StoreSubscriberStateType = LocationState

    static let sharedInstance = LocationProvider()
    private let locationManager: CLLocationManager

    private override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.locationState
            }.skipRepeats { $0 == $1 }
        }
    }

    deinit {
        unsubscribe()
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    var state: LocationState {
        return store.state.locationState
    }

    func newState(state: LocationState) {
        if shouldRequestAuthorization(state: state) {
            locationManager.requestWhenInUseAuthorization()
        } else if shouldRequestLocation(state: state) {
            locationManager.requestLocation()
        } else if shouldAlertThatLocationServicesNotPermitted(state: state) {
            let action = RequestLocationResultFailed(errorMessage: "To use this feature, please go to Settings > Privacy to enable location services")
            store.dispatch(action)
        }
    }

    func shouldRequestAuthorization(state: LocationState) -> Bool {
        return state.userHasRequestedLocationState && CLLocationManager.authorizationStatus() == .notDetermined
    }

    func shouldRequestLocation(state: LocationState) -> Bool {
        return state.userHasRequestedLocationState && CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }

    func shouldAlertThatLocationServicesNotPermitted(state: LocationState) -> Bool {
        return state.userHasRequestedLocationState && CLLocationManager.authorizationStatus() == .denied
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization authorizationStatus: CLAuthorizationStatus) {
        store.dispatch(LocationAuthorizationChanged(authorizationStatus: authorizationStatus))

        if state.userHasRequestedLocationState && authorizationStatus == .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let locationAction = RequestLocationResultSucceeded(locationCoordinate: lastLocation.coordinate)
            store.dispatch(locationAction)
            let addressAction = LookupAddressRequestCoordinates(location: lastLocation)
            store.dispatch(addressAction)
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        let action = RequestLocationResultFailed(errorMessage: error.localizedDescription)
        store.dispatch(action)
    }
}
