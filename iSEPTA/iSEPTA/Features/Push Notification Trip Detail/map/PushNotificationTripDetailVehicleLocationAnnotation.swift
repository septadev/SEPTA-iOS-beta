//
//  PushNotificationTripDetailVehicleLocationAnnotation.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import MapKit


class PushNotificationTripDetailVehicleLocationAnnotation: MKPointAnnotation {
    let tripDetailData: PushNotificationTripDetailData
    init(tripDetailData: PushNotificationTripDetailData) {
        self.tripDetailData = tripDetailData
    }
}
