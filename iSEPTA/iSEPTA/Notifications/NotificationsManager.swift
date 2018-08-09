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

public typealias PayLoad = [AnyHashable: Any]

struct NotificationsManager {
    struct Keys {
        static let notificationTypeKey = "notificationType"
        static let notificationKey = "notification"
        static let fcmTokenKey = "fcmTokenKey"
        static let septaAnnouncementTopic = "TOPIC_SEPTA_ANNOUNCEMENTS"
        static let notificationIdentifier = "SEPTALocalNotification"
    }
}

enum NotificationError: Error {
    case registrationTokenMissing
}
