//
//  ScheduleReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class ScheduleReducers {

    class func main(action _: Action, state: ScheduleState?) -> ScheduleState {
        guard let state = state else { return initializeScheduleState() }
        return initializeScheduleState()
    }

    class func initializeScheduleState() -> ScheduleState {
        let scheduleRequest = ScheduleRequest(transitMode: getDefaultTransitMode())

        return ScheduleState(scheduleRequest: scheduleRequest)
    }

    class func getDefaultTransitMode() -> TransitMode? {
        let prefProvider = stateProviders.preferenceProvider
        if let transitModeString = prefProvider.stringPreference(forKey: .preferredTransitMode) {
            return TransitMode(rawValue: transitModeString)
        } else {
            let defaultTransitMode = UserPreferenceKeys.preferredTransitMode.defaultValue()
            return TransitMode(rawValue: defaultTransitMode ?? "")
        }
    }
}
