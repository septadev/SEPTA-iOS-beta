// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class AppStateReducer {

    class func mainReducer(action: Action, state: AppState?) -> AppState {
        return AppState(
            navigationState: NavigationReducer.main(action: action, state: state?.navigationState),
            scheduleState: ScheduleReducer.main(action: action, state: state?.scheduleState),
            preferenceState: UserPreferenceReducer.main(action: action, state: state?.preferenceState)
        )
    }
}
