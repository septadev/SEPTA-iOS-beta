// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol UserPreferencesAction: SeptaAction {}

protocol ToggleSwitchAction: SeptaAction {
    var boolValue: Bool { get set }
}

struct NewTransitModeAction: UserPreferencesAction {
    let transitMode: TransitMode
    let description = "User Switched Transit Mode"
}

struct PreferencesRetrievedAction: UserPreferencesAction {
    let userPreferenceState: UserPreferenceState
    let description = "Just retrieved preferences from defaults"
}

struct PreferencesDatabaseLoaded: UserPreferencesAction {
    let databaseVersion: Int
    let description = "A database version has been loaded"
}

struct NewStartupController: UserPreferencesAction {
    let navigationController: NavigationController
    let description = "New Startup Controller should be saved to prefs"
}

struct UpdatePushNotificationPreferenceState: UserPreferencesAction {
    let pushNotificationPreferenceState: PushNotificationPreferenceState
    let description = "A new preference state for push notifications has been set"
}

struct UserWantsToSubscribeToPushNotifications: UserPreferencesAction, ToggleSwitchAction {
    var boolValue: Bool = false
    let description = "Toggling Push Notification preference State"
}

struct UserWantsToSubscribeToSpecialAnnouncements: UserPreferencesAction, ToggleSwitchAction {
    var boolValue: Bool = false
    let description = "Toggling Wants to Receive Special Announcements"
}

struct UserWantsToSubscribeToOverideDoNotDisturb: UserPreferencesAction, ToggleSwitchAction {
    var boolValue: Bool = false
    let description = "Toggling Wants to ignore Do Not Disturb"
}

struct UpdateSystemAuthorizationStatusForPushNotifications: UserPreferencesAction {
    let authorizationStatus: PushNotificationAuthorizationState
    let description = "Authorization Status for Push Notifications"
}

struct UpdateDaysOfTheWeekForPushNotifications: UserPreferencesAction {
    let dayOfWeek: DaysOfWeekOptionSet
    let isActivated: Bool
    let description = "Toggling a particular day of the week for notifications"
}

struct UpdatePushNotificationTimeframe: UserPreferencesAction {
    let description = "Updating a timeframe"
    let block: (UserPreferenceState) -> UserPreferenceState
}

struct InsertNewPushTimeframe: UserPreferencesAction {
    let description = "Adding a new time frame"
}

struct DeleteTimeframe: UserPreferencesAction {
    let index: Int
    let description = "Deleting a new time frame"
}
