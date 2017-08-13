// Septa. 2017

import Foundation

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
