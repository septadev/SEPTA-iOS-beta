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
            preferenceState: UserPreferenceReducer.main(action: action, state: state?.preferenceState)
        )

        StateLogger.sharedInstance.logAction(stateBefore: state, action: action, stateAfter: appState,
                                             consoleLogObjects: [action, appState.scheduleState.scheduleRequest])
        return appState
    }
}
