//
//  PreferenceReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class UserPreferenceReducers {

    class func main(action: Action, state: UserPreferenceState?) -> UserPreferenceState {
        let newState = state ?? PreferencesProvider.sharedInstance.retrievePersistedState()
        guard let action = action as? UserPreferenceAction else { return newState }

        
    switch action {
        case let preferenceRetrievedAction as UserPreference.PreferencesRetrievedAction:
            return updateModelFromPreferences(action: preferenceRetrievedAction, state: newState)

        default:
            return newState
        }
    }

    class func updateModelFromPreferences(action: UserPreference.PreferencesRetrievedAction, state: UserPreferenceState) -> UserPreferenceState {
        return action.preferenceState
    }
}
