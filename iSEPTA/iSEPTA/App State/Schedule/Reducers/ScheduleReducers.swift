// Septa. 2017

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

    class func handleScheduleActions(action _: ScheduleAction, state _: ScheduleState) -> ScheduleState {
        return ScheduleState()
    }

    class func newSchedule(transitMode: TransitMode) -> ScheduleState {
        let request = ScheduleRequest(selectedRoute: nil, selectedStart: nil, selectedEnd: nil, transitMode: transitMode)
        return ScheduleState(scheduleRequest: request, scheduleData: nil)
    }

    class func updatePreferences(state: [String: String]?, withString value: String, forKey key: String) -> [String: String] {

        if var state = state {
            state[key] = value
            return state

        } else {
            return [key: value]
        }
    }
}
