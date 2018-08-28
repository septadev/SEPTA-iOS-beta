//
//  NotificationManager+RemoteNotifications.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UserNotifications

extension NotificationsManager {
    static func handleRemoteNotification(info: PayLoad) {
        guard let notificationType = NotificationType(info: info),
            let notificationPreferences = decodeUserPushNotificationPreference() else { return }

        switch notificationType {
        case .delay:
            processDelay(notificationType: notificationType, pushNotificationPreferenceState: notificationPreferences, info: info)
        case .alert, .detour:
            processAlertDetour(notificationType: notificationType, pushNotificationPreferenceState: notificationPreferences, info: info)
        case .specialAnnouncement:
            processSpecialAnnouncement(notificationType: notificationType, pushNotificationPreferenceState: notificationPreferences, info: info)
        }
    }

    static func processDelay(notificationType: NotificationType, pushNotificationPreferenceState: PushNotificationPreferenceState, info: PayLoad) {
        guard let notif = SeptaDelayNotification(info: info),
            pushNotificationPreferenceState.userShouldReceiveNotification(atDate: Date(), routeId: notif.routeId, transitMode: notif.transitMode),
            let data = try? encoder.encode(notif),
            let payload = buildPayload(notificationType: notificationType, data: data) else { return }

        displayNotification(notification: notif, userInfo: payload)
    }

    static func processAlertDetour(notificationType: NotificationType, pushNotificationPreferenceState: PushNotificationPreferenceState, info: PayLoad) {
        guard let notif = SeptaAlertDetourNotification(info: info),
            pushNotificationPreferenceState.userShouldReceiveNotification(atDate: Date(), routeId: notif.routeId, transitMode: notif.transitMode),
            let data = try? encoder.encode(notif),
            let payload = buildPayload(notificationType: notificationType, data: data) else { return }

        displayNotification(notification: notif, userInfo: payload)
    }

    static func processSpecialAnnouncement(notificationType: NotificationType, pushNotificationPreferenceState: PushNotificationPreferenceState, info: PayLoad) {
        guard let notif = SeptaSpecialAnnouncementNotification(info: info),
            pushNotificationPreferenceState.userWantsToReceiveSpecialAnnoucements,
            let data = try? encoder.encode(notif),
            let payload = buildPayload(notificationType: notificationType, data: data) else { return }

        displayNotification(notification: notif, userInfo: payload)
    }

    static func buildPayload(notificationType: NotificationType, data: Data) -> PayLoad? {
        var payload = PayLoad()
        payload[Keys.notificationTypeKey] = notificationType.rawValue
        payload[Keys.notificationKey] = data
        return payload
    }

    private static func displayNotification(notification: SeptaNotification, userInfo: [AnyHashable: Any]) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.userInfo = userInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Keys.notificationIdentifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
}
