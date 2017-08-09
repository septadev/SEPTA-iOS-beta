// Septa. 2017

import Foundation
import UIKit
import ReSwift

struct NavigationReducers {

    static func main(action: Action, state: NavigationState?) -> NavigationState {
        guard let newState = state else { return NavigationState(selectedFeature: .noneSelected, activeFeature: .noneSelected) }
        guard let action = action as? NavigationAction else { return newState }
        return handleNavigationActions(action: action, state: newState)
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
