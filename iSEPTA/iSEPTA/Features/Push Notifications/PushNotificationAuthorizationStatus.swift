//
//  PushNotificationAuthorizationStatus.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/24/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UserNotifications

enum PushNotificationAuthorizationState: String, Codable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional

    init(status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .authorized: self = .authorized
        case .provisional: self = .provisional
        }
    }
}
