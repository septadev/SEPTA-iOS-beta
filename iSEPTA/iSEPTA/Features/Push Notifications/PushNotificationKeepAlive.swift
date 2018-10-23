//
//  PushNotificationKeepAlive.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/28/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

/// Our backend push notification provider has no idea when an app is uninstalled or a device is no
/// longer used. This struct exists to provide a "keep alive" service that will update the last date
/// saved on the backend. It is expected that the backend service will periodically wipe out "stale"
/// data in order to prevent an ever growing list of device notification preferences.

struct PushNotificationKeepAlive {
    private static let pushNotificationsLastSavedDateKey = "pushNotificationsLastSavedDateKey"

    static func post() {
        if let lastSave = UserDefaults.standard.object(forKey: pushNotificationsLastSavedDateKey) as? Date {
            let calendar = Calendar.current
            let componentFlags = Set<Calendar.Component>([.day])
            let components = calendar.dateComponents(componentFlags, from: lastSave, to: Date())
            if let numberOfDays = components.day {
                if numberOfDays >= 5 {
                    store.dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: false, viewController: nil))
                }
            }
        }
    }

    static func preferencesSaved() {
        UserDefaults.standard.set(Date(), forKey: pushNotificationsLastSavedDateKey)
    }
}
