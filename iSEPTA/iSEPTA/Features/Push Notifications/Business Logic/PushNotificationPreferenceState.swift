//
//  PushNotificationPreferenceState.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct PushNotificationPreferenceState: Codable, Equatable {
    /// An array of `RangeBounds` structs.
    /// For example:  [[start: 360, end: 720], [start: 900, end: 960]] means
    /// that the user wants to receive notifications between 6 AM and 12 PM.
    /// and from 5 - 6 PM.
    var notificationTimeWindows: [NotificationTimeWindow] = [NotificationTimeWindow.defaultValue()]

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

    /// This method indicates whether a push notification should be fired
    /// based on the user preferences described in this class.  Note that
    /// those preferences do not include whether or not the user has authorized
    /// push notifications in the first place.  That needs to be checked separately
    /// TODO we will probably want to move this method someplace else
    func userShouldReceiveNotification(atDate date: Date, pushNotificationRoute: PushNotificationRoute) -> Bool {
        let timeWindowsMatches = notificationTimeWindows.map { $0.dateFitsInRange(date: date) }
        return
            routeIds.filter({ $0.isEnabled }).contains(pushNotificationRoute) &&
            daysOfWeek.matchesDate(date) &&
            timeWindowsMatches.contains(true)
    }
}
