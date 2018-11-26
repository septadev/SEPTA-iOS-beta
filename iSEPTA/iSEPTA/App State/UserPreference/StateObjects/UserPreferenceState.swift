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
    var doNotShowThisAlertAgain: Bool
    var lastSavedDoNotShowThisAlertAgainState: String

    init(defaultsLoaded: Bool = false, startupTransitMode: TransitMode = .bus, startupNavigationController: NavigationController = .nextToArrive, databaseVersion: Int = 0, pushNotificationPreferenceState: PushNotificationPreferenceState = PushNotificationPreferenceState(), doNotShowThisAlertAgain: Bool = false, lastSavedDoNotShowThisAlertAgainState: String = "") {
        self.defaultsLoaded = defaultsLoaded
        self.startupTransitMode = startupTransitMode
        self.startupNavigationController = startupNavigationController
        self.databaseVersion = databaseVersion
        self.pushNotificationPreferenceState = pushNotificationPreferenceState
        self.doNotShowThisAlertAgain = doNotShowThisAlertAgain
        self.lastSavedDoNotShowThisAlertAgainState = lastSavedDoNotShowThisAlertAgainState
    }
}
