//
//  PushNotificationPreferenceState.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct PushNotificationPreferenceState: Codable, Equatable {
    /// The UUID of this app on this device
    let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""

    /// The token provided by Firebase that is required for sending push notifications to this device
    var firebaseToken: String = ""

    /// An array of `RangeBounds` structs.
    /// For example:  [[start: 360, end: 720], [start: 900, end: 960]] means
    /// that the user wants to receive notifications between 6 AM and 12 PM.
    /// and from 5 - 6 PM.
    var notificationTimeWindows: [NotificationTimeWindow] = [NotificationTimeWindow.defaultMorningWindow()]

    /// An OptionSet that allows users to the days of the week on which they wish to receive notifications.
    var daysOfWeek: DaysOfWeekOptionSet = DaysOfWeekOptionSet.mondayThroughFriday()

    /// The routes for which the user has subscribed to notifications
    var routeIds: [PushNotificationRoute] = [PushNotificationRoute]()

    /// Does the user want to receive notifications
    var userWantsToEnablePushNotifications: Bool = false

    /// Whether or not the OS thinks the user has authorized notifications
    var systemAuthorizationStatusForNotifications: PushNotificationAuthorizationState = .notDetermined

    /// Whether or not the user wants to receive SEPTA special announcements
    var userWantsToReceiveSpecialAnnoucements: Bool = false

    /// User Views SEPTA Notifications as priority that should override Do Not Disturb on the device
    var userWantToReceiveNotificationsEvenWhenDoNotDisturbIsOn: Bool = false

    /// Whether or not the push notification preferences should be posted to the backend API
    var postUserNotificationPreferences = false
}
