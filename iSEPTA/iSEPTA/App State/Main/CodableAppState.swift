// Septa. 2017

import Foundation

extension AppState {

    enum AppStateKeys: String, CodingKey {
        case navigationState
        case scheduleState
        case preferenceState
    }

    //    init(from decoder: Decoder) throws {
    //        let container = try decoder.container(keyedBy: AppStateKeys.self) // defining our (keyed) container
    //        let navigationState: NavigationState = try container.decode(NavigationState.self, forKey: .navigationState) // extracting the data
    //        let scheduleState: ScheduleState = try container.decode(ScheduleState.self, forKey: .scheduleState) // extracting the data
    //        let preferenceState: UserPreferenceState = try container.decode(UserPreferenceState.self, forKey: .preferenceState) // extracting the data
    //
    //        self.init(navigationState: navigationState, scheduleState: scheduleState, preferenceState: preferenceState) // initializing our struct
    //    }
    //
    //    func encode(to encoder: Encoder) throws {
    //        var container = encoder.container(keyedBy: AppStateKeys.self)
    //        try container.encode(navigationState, forKey: .navigationState)
    //        try container.encode(scheduleState, forKey: .scheduleState)
    //        try container.encode(preferenceState, forKey: .preferenceState)
    //    }
}
