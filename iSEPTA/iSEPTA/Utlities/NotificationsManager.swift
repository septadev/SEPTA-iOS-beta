//
//  NotificationsManager.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Firebase
import FirebaseMessaging
import Foundation

class NotificationsManager: NSObject {
    let fcmTokenKey = "fcmTokenKey"

    override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    func configure() {
        FirebaseApp.configure()
    }

    /// Subscribe to notifications for a given route ID.
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    func subscribe(routeId: String) throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }
        Messaging.messaging().subscribe(toTopic: routeId)
    }

    /// Unsubscribe to notifications for a given route ID.
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    func unsubscribe(routeId: String) throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }
        Messaging.messaging().unsubscribe(fromTopic: routeId)
    }

    private func userFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: fcmTokenKey)
    }
}

extension NotificationsManager: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
        UserDefaults.standard.setValue(fcmToken, forKey: fcmTokenKey)
    }
}

enum NotificationError: Error {
    case registrationTokenMissing
}
