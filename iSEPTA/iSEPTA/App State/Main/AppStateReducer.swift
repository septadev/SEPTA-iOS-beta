// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class AppStateReducer {
    static let encoder = JSONEncoder()

    class func mainReducer(action: Action, state: AppState?) -> AppState {

        let appState = AppState(
            navigationState: NavigationReducer.main(action: action, state: state?.navigationState),
            scheduleState: ScheduleReducer.main(action: action, state: state?.scheduleState),
            preferenceState: UserPreferencesReducer.main(action: action, state: state?.preferenceState),
            alertState: AlertReducer.main(action: action, state: state?.alertState),
            addressLookupState: AddressLookupReducer.main(action: action, state: state?.addressLookupState),
            locationState: LocationReducer.main(action: action, state: state?.locationState)
        )

        return appState
    }
}
