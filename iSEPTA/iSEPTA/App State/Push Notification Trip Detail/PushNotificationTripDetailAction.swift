//
//  PushNotificationTripDetailAction.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

protocol PushNotificationTripDetailAction: SeptaAction {}

struct UpdatePushNotificationTripDetail: PushNotificationTripDetailAction {
    let tripDetails: NextToArriveRailDetails
    let description: String = "Updating Push Notification Trip Details"
}

struct ClearPushNotificationTripDetail: PushNotificationTripDetailAction {
    let description: String = "Clear out push notification Trip Details"
}
