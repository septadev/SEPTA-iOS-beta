//
//  UserPreferenceActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol UserPreferenceAction: Action {}

class UserPreference {
    struct NewTransitModeAction: UserPreferenceAction {
        let transitMode: TransitMode
    }

    struct PreferencesRetrievedAction: UserPreferenceAction {
        let preferenceState : UserPreferenceState
    }
}
