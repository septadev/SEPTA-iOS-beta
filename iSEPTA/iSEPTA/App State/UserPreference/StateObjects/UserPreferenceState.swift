// Septa. 2017

import Foundation
import SeptaSchedule

struct UserPreferenceState: Equatable {
    var defaultsLoaded: Bool
    var startupTransitMode: TransitMode
    var startupNavigationController: NavigationController
    var databaseVersion: Int
    var pushNotificationPreferenceState: PushNotificationPreferenceState
    var lastSavedPushPreferenceState: PushNotificationPreferenceState?
    // TODO: JJ 2
    var doNotShowGenericAlertAgain: Bool
    var lastSavedDoNotShowGenericAlertAgainState: String
    var doNotShowAppAlertAgain: Bool
    var lastSavedDoNotShowAppAlertAgainState: String

    init(defaultsLoaded: Bool = false, startupTransitMode: TransitMode = .bus, startupNavigationController: NavigationController = .nextToArrive, databaseVersion: Int = 0, pushNotificationPreferenceState: PushNotificationPreferenceState = PushNotificationPreferenceState(), doNotShowGenericAlertAgain: Bool = false, lastSavedDoNotShowGenericAlertAgainState: String = "", doNotShowAppAlertAgain: Bool = false, lastSavedDoNotShowAppAlertAgainState: String = "") {
        self.defaultsLoaded = defaultsLoaded
        self.startupTransitMode = startupTransitMode
        self.startupNavigationController = startupNavigationController
        self.databaseVersion = databaseVersion
        self.pushNotificationPreferenceState = pushNotificationPreferenceState
        self.doNotShowGenericAlertAgain = doNotShowGenericAlertAgain
        self.lastSavedDoNotShowGenericAlertAgainState = lastSavedDoNotShowGenericAlertAgainState
        self.doNotShowAppAlertAgain = doNotShowAppAlertAgain
        self.lastSavedDoNotShowAppAlertAgainState = lastSavedDoNotShowAppAlertAgainState
    }
}
