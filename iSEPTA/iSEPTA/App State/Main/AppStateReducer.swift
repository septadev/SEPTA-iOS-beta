// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class AppStateReducer {

    class func mainReducer(action: Action, state: AppState?) -> AppState {
        let appState = AppState(
            navigationState: NavigationReducer.main(action: action, state: state?.navigationState),
            scheduleState: ScheduleReducer.main(action: action, state: state?.scheduleState),
            preferenceState: UserPreferenceReducer.main(action: action, state: state?.preferenceState)
        )

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(appState)
            let json = String(data: jsonData, encoding: .utf8)
            print(json!)
        } catch {
            print(error.localizedDescription)
        }
        return appState
    }
}
