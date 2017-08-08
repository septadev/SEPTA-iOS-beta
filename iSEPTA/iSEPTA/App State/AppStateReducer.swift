// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class AppStateReducer {

    class func mainReducer(action: Action, state: AppState?) -> AppState {
        return AppState(
            navigationState: NavigationReducers.main(action: action, state: state?.navigationState),
            scheduleState: ScheduleReducers.main(action: action, state: state?.scheduleState),
            preferenceState: UserPreferenceReducers.main(action: action, state: state?.preferenceState)
        )
    }
}
