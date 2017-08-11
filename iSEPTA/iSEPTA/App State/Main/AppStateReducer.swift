// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class AppStateReducer {
    static let encoder = JSONEncoder()

    class func mainReducer(action: Action, state: AppState?) -> AppState {
        logAction(action)

        let appState = AppState(
            navigationState: NavigationReducer.main(action: action, state: state?.navigationState),
            scheduleState: ScheduleReducer.main(action: action, state: state?.scheduleState),
            preferenceState: UserPreferenceReducer.main(action: action, state: state?.preferenceState)
        )

        logState(appState)

        return appState
    }

    class func logAction(_ action: Action) {
        guard let action = action as? SeptaAction else { return }
        print("****  \(action.self)")
        print(action.description)
    }

    class func logState(_ appState: AppState) {
        do {
            let jsonData = try encoder.encode(appState.navigationState)
            let json = String(data: jsonData, encoding: .utf8)
            print(json!)
        } catch {
            print(error.localizedDescription)
        }
    }
}
