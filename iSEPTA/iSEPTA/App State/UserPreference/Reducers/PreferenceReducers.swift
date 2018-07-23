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
            newPref = reducePreferencesRetrievedAction(action: action, state: state)
        case let action as NewTransitModeAction:
            newPref = reduceNewTransitModeAction(action: action, state: state)
        case let action as PreferencesDatabaseLoaded:
            newPref = reducePreferencesDatabaseLoaded(action: action, state: state)
        case let action as NewStartupController:
            newPref = reduceNewStartupController(action: action, state: state)
        case let action as UpdatePushNotificationPreferenceState:
            newPref = reduceUpdatePushNotificationPreferenceState(action: action, state: state)
        default:
            break
        }

        return newPref
    }

    static func reducePreferencesRetrievedAction(action: PreferencesRetrievedAction, state _: UserPreferenceState) -> UserPreferenceState {
        return action.userPreferenceState
    }

    static func reduceNewTransitModeAction(action: NewTransitModeAction, state: UserPreferenceState) -> UserPreferenceState {
        return UserPreferenceState(defaultsLoaded: state.defaultsLoaded, startupTransitMode: action.transitMode, startupNavigationController: state.startupNavigationController, databaseVersion: state.databaseVersion)
    }

    static func reducePreferencesDatabaseLoaded(action: PreferencesDatabaseLoaded, state: UserPreferenceState) -> UserPreferenceState {
        return UserPreferenceState(defaultsLoaded: state.defaultsLoaded, startupTransitMode: state.startupTransitMode, startupNavigationController: state.startupNavigationController, databaseVersion: action.databaseVersion)
    }

    static func reduceNewStartupController(action: NewStartupController, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.startupNavigationController = action.navigationController
        return userPreferenceState
    }

     static func reduceUpdatePushNotificationPreferenceState(action: UpdatePushNotificationPreferenceState, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState = action.pushNotificationPreferenceState
        return userPreferenceState
    }
}
