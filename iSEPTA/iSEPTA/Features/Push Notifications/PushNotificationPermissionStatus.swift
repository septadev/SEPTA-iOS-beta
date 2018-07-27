//
//  UserNotificationSettings.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/24/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UserNotifications

struct PushNotificationPermissionStatus: Codable, Equatable {
    var authorizationStateInSettings = PushNotificationAuthorizationState.notDetermined
    var authorizationStateInApp = PushNotificationAuthorizationState.notDetermined
}


