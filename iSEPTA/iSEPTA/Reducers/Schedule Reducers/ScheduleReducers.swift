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

    class func main(action: Action, state: ScheduleState?) -> ScheduleState {
        guard let newState = state else { return initializeScheduleState() }
        guard let action = action as? ScheduleAction else { return newState }
        return handleScheduleActions(action: action, state: newState)
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

    class func handleScheduleActions(action: ScheduleAction, state: ScheduleState) -> ScheduleState {
        switch action {
        case let action as ScheduleActions.TransitModeSelected:
            updatePreferences(transitMode: action.transitMode)
            return newSchedule(transitMode: action.transitMode)
        default:
            return state
        }
    }

    class func newSchedule(transitMode: TransitMode) -> ScheduleState {
        let request = ScheduleRequest(selectedRoute: nil, selectedStart: nil, selectedEnd: nil, transitMode: transitMode)
        return ScheduleState(scheduleRequest: request, scheduleData: nil)
    }

    class func updatePreferences(transitMode: TransitMode) {
        stateProviders.preferenceProvider.setStringPreference(preference: transitMode.rawValue, forKey: .preferredTransitMode)
    }
}
