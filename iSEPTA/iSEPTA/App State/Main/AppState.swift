// Septa. 2017

import Foundation
import ReSwift

struct AppState: StateType {
    let navigationState: NavigationState
    let scheduleState: ScheduleState
    let preferenceState: UserPreferenceState
    let alertState: AlertState

    init(navigationState: NavigationState, scheduleState: ScheduleState, preferenceState: UserPreferenceState, alertState: AlertState) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
        self.preferenceState = preferenceState
        self.alertState = alertState
    }
}

extension AppState: Equatable {}
func ==(lhs: AppState, rhs: AppState) -> Bool {
    var areEqual = true

    areEqual = lhs.navigationState == rhs.navigationState
    guard areEqual else { return false }

    areEqual = lhs.scheduleState == rhs.scheduleState
    guard areEqual else { return false }

    areEqual = lhs.preferenceState == rhs.preferenceState
    guard areEqual else { return false }

    areEqual = lhs.alertState == rhs.alertState
    guard areEqual else { return false }

    return areEqual
}
