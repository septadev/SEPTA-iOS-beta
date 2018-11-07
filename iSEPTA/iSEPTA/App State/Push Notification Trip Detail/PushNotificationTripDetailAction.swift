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

struct UpdatePushNotificationTripDetailTripId: PushNotificationTripDetailAction {
    let description: String = "A Push Notification has been received with a specific trip ID"
    let tripId: String
}

struct UpdatePushNotificationTripDetailStatus: PushNotificationTripDetailAction {
    let description: String = "The status for updating Trip Detail has changed"
    let status: PushNotificationTripDetailStatus
}

struct UpdatePushNotificationTripDetailData: PushNotificationTripDetailAction {
    let pushNotificationTripDetailData: PushNotificationTripDetailData
    let description: String = "Updating Push Notification Trip Details"
}

struct ClearPushNotificationTripDetailData: PushNotificationTripDetailAction {
    let description: String = "Clear out push notification Trip Details"
}
