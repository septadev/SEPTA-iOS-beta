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
        guard let newState = state else { return UserPreferenceState() }
        guard let action = action as? UserPreferenceAction else { return newState }
        return newState
    }
}
