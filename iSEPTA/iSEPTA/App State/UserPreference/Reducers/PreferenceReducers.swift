// Septa. 2017

import Foundation
import ReSwift

struct UserPreferencesReducer {

    static func main(action: Action, state: UserPreferenceState?) -> UserPreferenceState {

        if let state = state {
            guard let action = action as? UserPreferencesAction else { return state }

            return reducePreferenceActions(action: action, state: state)

        } else {
            return UserPreferenceState()
        }
    }

    static func reducePreferenceActions(action: UserPreferencesAction, state: UserPreferenceState) -> UserPreferenceState {
        var newPref = state
        switch action {
        case let action as PreferencesRetrievedAction:
            return reducePreferencesRetrievedAction(action: action, state: state)
        case let action as NewTransitModeAction:
            newPref.startupTransitMode = action.transitMode
        default:
            break
        }

        return newPref
    }

    static func reducePreferencesRetrievedAction(action: PreferencesRetrievedAction, state _: UserPreferenceState) -> UserPreferenceState {
        return action.userPreferenceState
    }
}
