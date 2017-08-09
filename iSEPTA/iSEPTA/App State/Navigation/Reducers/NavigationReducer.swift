// Septa. 2017

import Foundation
import ReSwift

struct NavigationReducer {
    static func main(action: Action, state: NavigationState?) -> NavigationState {
        if let navState = state {
            guard let navigationAction = action as? NavigationAction else { return navState }
            return handleNavigationActions(action: navigationAction, state: navState)
        } else {

            return NavigationState(selectedFeature: .schedules, activeFeature: .noneSelected)
        }
    }

    static func handleNavigationActions(action: NavigationAction, state: NavigationState) -> NavigationState {
        switch action {
        case let action as SwitchFeature:
            return switchTabs(action: action, state: state)
        default:
            return state
        }
    }

    static func switchTabs(action: NavigationAction, state: NavigationState) -> NavigationState {

        switch action {
        case let action as SwitchFeature:
            return NavigationState(selectedFeature: action.selectedFeature, activeFeature: .noneSelected)
        case let action as SwitchFeatureCompleted:
            return NavigationState(selectedFeature: state.selectedFeature, activeFeature: action.activeFeature)
        default:
            return state
        }
    }
}
