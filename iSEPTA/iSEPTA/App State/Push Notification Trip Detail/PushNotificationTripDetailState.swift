//
//  PushNotificationTripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

struct PushNotificationTripDetailState: Equatable {
    var pushNotificationTripDetailUpdateStatus: PushNotificationTripDetailStatus = .idle
    var pushNotificationTripDetailData: PushNotificationTripDetailData?
    var tripId: String?
}
