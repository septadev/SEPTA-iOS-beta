// Septa. 2017

import Foundation
import ReSwift

struct AppState: StateType {
    let navigationState: NavigationState
    let scheduleState: ScheduleState
    let preferenceState: UserPreferenceState
    let alertState: AlertState
    let addressLookupState: AddressLookupState
    let locationState: LocationState

    init(navigationState: NavigationState, scheduleState: ScheduleState, preferenceState: UserPreferenceState, alertState: AlertState, addressLookupState: AddressLookupState, locationState: LocationState) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
        self.preferenceState = preferenceState
        self.alertState = alertState
        self.addressLookupState = addressLookupState
        self.locationState = locationState
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

    areEqual = lhs.addressLookupState == rhs.addressLookupState
    guard areEqual else { return false }

    areEqual = lhs.locationState == rhs.locationState
    guard areEqual else { return false }

    return areEqual
}
