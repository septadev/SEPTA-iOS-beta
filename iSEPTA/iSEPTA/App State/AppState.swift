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

extension AppState: Equatable {}
func ==(lhs: AppState, rhs: AppState) -> Bool {
    var areEqual = true

    if lhs.navigationState == rhs.navigationState {
        areEqual = true
    } else {
        return false
    }

    if lhs.scheduleState == rhs.scheduleState {
        areEqual = true
    } else {
        return false
    }

    if lhs.preferenceState == rhs.preferenceState {
        areEqual = true
    } else {
        return false
    }
    return areEqual
}
