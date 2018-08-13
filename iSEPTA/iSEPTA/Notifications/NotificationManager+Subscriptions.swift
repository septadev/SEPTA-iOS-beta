//
//  NotificationManager+Subscriptions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Firebase
import FirebaseMessaging
import Foundation
import SeptaSchedule
import UserNotifications

extension NotificationsManager {
    static func configure() {
        FirebaseApp.configure()
    }

    /// Subscribe to detour, alert, and delay notifications for a given route ID.
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    static func subscribe(routeId: String) throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }
        Messaging.messaging().subscribe(toTopic: detourTopic(routeId: routeId))
        Messaging.messaging().subscribe(toTopic: alertTopic(routeId: routeId))
        Messaging.messaging().subscribe(toTopic: delayTopic(routeId: routeId))
    }

    /// Unsubscribe from detour, alert, and delay notifications for a given route ID.
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    static func unsubscribe(routeId: String) throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }
        Messaging.messaging().unsubscribe(fromTopic: detourTopic(routeId: routeId))
        Messaging.messaging().unsubscribe(fromTopic: alertTopic(routeId: routeId))
        Messaging.messaging().unsubscribe(fromTopic: delayTopic(routeId: routeId))
    }

    /// Subscribe to special announcements notifications
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    static func subscribeToSpecialAnnouncements() throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }
        Messaging.messaging().subscribe(toTopic: Keys.septaAnnouncementTopic)
    }

    /// Unsubscribe from special announcement notifications
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    static func unSubscribeToSpecialAnnouncements() throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }

        Messaging.messaging().unsubscribe(fromTopic: Keys.septaAnnouncementTopic)
    }

    private static func userFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.fcmTokenKey)
    }

    private static func detourTopic(routeId: String) -> String {
        return "TOPIC_\(routeId)_\(NotificationType.detour.rawValue)"
    }

    private static func alertTopic(routeId: String) -> String {
        return "TOPIC_\(routeId)_\(NotificationType.alert.rawValue)"
    }

    private static func delayTopic(routeId: String) -> String {
        return "TOPIC_\(routeId)_\(NotificationType.delay.rawValue)"
    }
}
