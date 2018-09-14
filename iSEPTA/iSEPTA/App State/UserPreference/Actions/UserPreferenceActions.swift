// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

protocol UserPreferencesAction: SeptaAction {}
protocol PushNotificationAuthorizatonRequired: UserPreferencesAction {
    var viewController: UIViewController? { get }
}

protocol ToggleSwitchAction: PushNotificationAuthorizatonRequired {
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

/// Used only for unit tests
struct UpdatePushNotificationPreferenceState: UserPreferencesAction {
    let pushNotificationPreferenceState: PushNotificationPreferenceState
    let description = "A new preference state for push notifications has been set"
}

struct SetFirebaseTokenForPushNotificatoins: UserPreferencesAction {
    let token: String
    var description = "New Firebase token received"
}

struct UserWantsToSubscribeToPushNotifications: UserPreferencesAction, PushNotificationAuthorizatonRequired, ToggleSwitchAction {
    let viewController: UIViewController?
    var boolValue: Bool = false
    let alsoEnableRoutes: Bool
    let description = "Toggling Push Notification preference State"
    init(viewController: UIViewController?, boolValue: Bool = false, alsoEnableRoutes: Bool = true) {
        self.viewController = viewController
        self.boolValue = boolValue
        self.alsoEnableRoutes = alsoEnableRoutes
    }
}

struct UserWantsToSubscribeToSpecialAnnouncements: UserPreferencesAction, PushNotificationAuthorizatonRequired, ToggleSwitchAction {
    let viewController: UIViewController?
    var boolValue: Bool = false
    let description = "Toggling Wants to Receive Special Announcements"
    var sender: String
    init(viewController: UIViewController?, boolValue: Bool = false, sender: String = "DefaultSender") {
        self.viewController = viewController
        self.sender = sender
        self.boolValue = boolValue
    }
}

struct UpdateSystemAuthorizationStatusForPushNotifications: UserPreferencesAction {
    let authorizationStatus: PushNotificationAuthorizationState
    let description = "Authorization Status for Push Notifications"
}

struct UpdateDaysOfTheWeekForPushNotifications: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let dayOfWeek: DaysOfWeekOptionSet
    let isActivated: Bool
    let viewController: UIViewController?
    let description = "Toggling a particular day of the week for notifications"
}

struct UpdatePushNotificationTimeframe: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let description = "Updating a timeframe"
    let viewController: UIViewController?
    let block: (UserPreferenceState) -> UserPreferenceState
}

struct InsertNewPushTimeframe: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let viewController: UIViewController?
    let description = "Adding a new time frame"
}

struct DeleteTimeframe: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let index: Int
    let viewController: UIViewController?
    let description = "Deleting a new time frame"
}

struct RemovePushNotificationRoute: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let routes: [PushNotificationRoute]
    let viewController: UIViewController?
    let description = "Adding a push Notification Route"
}

struct UpdatePushNotificationRoute: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let route: PushNotificationRoute
    let postImmediately: Bool
    let viewController: UIViewController?
    let description = "Adding a push Notification Route"
}

struct ToggleAllPushNotificationRoutes: UserPreferencesAction {
    var boolValue: Bool
    let description = "Toggling all push notification Routes"
}

struct PostPushNotificationPreferences: UserPreferencesAction, PushNotificationAuthorizatonRequired {
    let postNow: Bool
    let showSuccess: Bool
    let viewController: UIViewController?
    let description = "Save push notification preferences to backend"
}

struct PushNotificationPreferenceSynchronizationSuccess: UserPreferencesAction {
    var description = "Push notification preferences were successfully saved in backend"
}

struct PushNotificationPreferenceSynchronizationFail: UserPreferencesAction {
    var description = "Push notification preferences failed to be saved in backend"
}
