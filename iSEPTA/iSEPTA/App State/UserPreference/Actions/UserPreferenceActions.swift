// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

protocol UserPreferencesAction: SeptaAction {}

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
