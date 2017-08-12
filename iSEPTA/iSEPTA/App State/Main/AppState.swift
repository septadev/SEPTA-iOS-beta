// Septa. 2017

import Foundation
import ReSwift

struct AppState: StateType {
    let navigationState: NavigationState
    let scheduleState: ScheduleState
    let preferenceState: UserPreferenceState

    init(navigationState: NavigationState, scheduleState: ScheduleState, preferenceState: UserPreferenceState) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
        self.preferenceState = preferenceState
    }
}
