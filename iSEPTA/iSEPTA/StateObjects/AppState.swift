// Septa. 2017

import Foundation
import ReSwift

struct AppState: StateType {
    let navigationState: NavigationState
    let scheduleState: ScheduleState
    public init(navigationState: NavigationState, scheduleState: ScheduleState) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
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
    return areEqual
}
