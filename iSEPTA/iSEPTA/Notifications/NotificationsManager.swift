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
import SeptaSchedule
import UserNotifications

struct NotificationsManager {
    static let fcmTokenKey = "fcmTokenKey"
    static let septaAnnouncementTopic = "TOPIC_SEPTA_ANNOUNCEMENTS"

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
        Messaging.messaging().subscribe(toTopic: septaAnnouncementTopic)
    }

    /// Unsubscribe from special announcement notifications
    /// Throws NotificationError.registrationTokenMissing error if a Firebase Cloud Messaging token has not previously been received
    static func unSubscribeToSpecialAnnouncements() throws {
        guard let _ = userFCMToken() else {
            throw NotificationError.registrationTokenMissing
        }

        Messaging.messaging().unsubscribe(fromTopic: septaAnnouncementTopic)
    }

    static func handleRemoteNotification(info: [AnyHashable: Any]) {
        let payload = SeptaNotification(payload: info)

        guard let type = payload.type,
            let msg = payload.message,
            let expireDate = payload.expires,
            let notificationPreference = decodeUserPushNotificationPreference() else { return }

        if expireDate < Date() {
            // Notification has expired, don't show
            return
        }

        if type == .specialAnnouncement {
            if notificationPreference.userWantsToReceiveSpecialAnnoucements {
                let title = buildTitle(for: .specialAnnouncement, routeId: "")
                displayNotification(title: title, message: msg)
            }
            return
        }

        // For notificatoins that are not Special Announcements, route ID and route type are required
        guard let routeId = payload.routeId,
            let routeType = payload.routeType else { return }

        let transitMode = transitModeFromRouteType(routeType: routeType)
        if notificationPreference.userShouldReceiveNotification(atDate: Date(), routeId: routeId, transitMode: transitMode) {
            let title = buildTitle(for: type, routeId: routeId)
            displayNotification(title: title, message: msg)
        }
    }

    private static func transitModeFromRouteType(routeType: RouteType) -> TransitMode {
        switch routeType {
        case .bus:
            return TransitMode.bus
        case .rail:
            return TransitMode.rail
        case .trolley:
            return TransitMode.trolley
        case .subway:
            return TransitMode.subway
        case .nhsl:
            return TransitMode.nhsl
        }
    }

    private static func decodeUserPushNotificationPreference() -> PushNotificationPreferenceState? {
        let defaults = UserDefaults.standard
        let preferenceKey = UserPreferencesKeys.pushNotificationPreferenceState.rawValue
        if let data = defaults.data(forKey: preferenceKey),
            let jsonData = try? JSONDecoder().decode(PushNotificationPreferenceState.self, from: data) {
            return jsonData
        }
        return nil
    }

    private static func displayNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "SEPTALocalNotification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }

    private static func buildTitle(for type: NotificationType, routeId: String) -> String {
        switch type {
        case .specialAnnouncement:
            return "Special Announcement"
        case .alert:
            return "Service Alert for Route \(routeId)"
        case .detour:
            return "Detour on Route \(routeId)"
        case .delay:
            return "Train Delay on \(routeId)"
        }
    }

    private static func userFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: fcmTokenKey)
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

enum NotificationError: Error {
    case registrationTokenMissing
}
