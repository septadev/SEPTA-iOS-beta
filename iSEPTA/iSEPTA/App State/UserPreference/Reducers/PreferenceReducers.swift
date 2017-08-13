// Septa. 2017

import Foundation
import ReSwift

struct UserPreferenceReducer {

    static func main(action: Action, state: UserPreferenceState?) -> UserPreferenceState {

        if let prefState = state {
            guard let prefAction = action as? UserPreferenceAction else { return prefState }

            return reducePreference(action: prefAction, userPreferenceState: prefState)
        } else {

            return UserPreferenceState()
        }
    }

    static func reducePreference(action: UserPreferenceAction, userPreferenceState: UserPreferenceState) -> UserPreferenceState {
        var newPref = userPreferenceState
        switch action {
        case let action as UserPreference.NewTransitModeAction:
            newPref.startupTransitMode = action.transitMode
        default:
            newPref = userPreferenceState
        }
        return newPref
    }

    static func updateModelFromPreferences(action: UserPreference.PreferencesRetrievedAction, state _: UserPreferenceState) -> UserPreferenceState {
        return action.preferenceState
    }
}
