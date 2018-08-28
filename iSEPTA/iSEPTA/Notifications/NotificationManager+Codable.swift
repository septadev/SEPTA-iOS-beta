//
//  NotificationManager+Codable.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

extension NotificationsManager {
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatters.networkFormatter)
        return encoder
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatters.networkFormatter)
        return decoder
    }

    static func decodeUserPushNotificationPreference() -> PushNotificationPreferenceState? {
        let defaults = UserDefaults.standard
        let preferenceKey = UserPreferencesKeys.pushNotificationPreferenceState.rawValue
        if let data = defaults.data(forKey: preferenceKey),
            let jsonData = try? JSONDecoder().decode(PushNotificationPreferenceState.self, from: data) {
            return jsonData
        }
        return nil
    }
}
