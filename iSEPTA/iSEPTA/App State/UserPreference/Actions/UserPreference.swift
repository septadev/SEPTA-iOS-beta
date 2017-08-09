// Septa. 2017

import Foundation
import ReSwift

protocol UserPreferenceAction: Action {}

struct UserPreference {
    struct NewTransitModeAction: UserPreferenceAction {
        let transitMode: TransitMode
    }

    struct PreferencesRetrievedAction: UserPreferenceAction {
        let preferenceState: UserPreferenceState
    }
}
