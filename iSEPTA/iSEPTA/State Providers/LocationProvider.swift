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

    func newState(state _: LocationState) {
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        //        if status == .authorizedWhenInUse {
        //            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        //                if CLLocationManager.isRangingAvailable() {
        //                    // do stuff
        //                }
        //            }
        //        }
    }
}
