// Septa. 2017

import Foundation
import ReSwift

struct NavigationReducer {
    static func main(action: Action, state: NavigationState?) -> NavigationState {

        if let state = state {
            guard let action = action as? NavigationAction else { return state }

            return reduceNavigationActions(action: action, state: state)

        } else {
            return NavigationState(
                appStackState: nil,
                selectedTab: NavigationController.schedules.tabIndex())
        }
    }

    static func reduceNavigationActions(action: NavigationAction, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState ?? AppStackState()
        var selectedTab = state.selectedTab
        switch action {
        case let action as InitializeNavigationState:
            appStackState = reduceInitializeViewAction(action: action, state: appStackState)
        case let action as TransitionView:
            appStackState = reduceTransitionViewAction(action: action, state: appStackState)
        case let action as SwitchTabs:
            selectedTab = action.tabBarItemIndex
        case let action as DismissModal:
            appStackState = reduceDismissModalAction(action: action, state: appStackState)
        default:
            return state
        }

        return NavigationState(appStackState: appStackState, selectedTab: selectedTab)
    }

    static func reduceInitializeViewAction(action: InitializeNavigationState, state: AppStackState) -> AppStackState {
        var newState = state
        newState[action.navigationController] = action.navigationStackState
        return newState
    }

    static func reduceTransitionViewAction(action: TransitionView, state: AppStackState) -> AppStackState {
        var newState = state
        var navigationStackState = state[action.navigationController] ?? NavigationStackState()
        var viewControllers = navigationStackState.viewControllers ?? [ViewController]()
        var modalViewController = navigationStackState.modalViewController
        switch action.viewTransitionType {
        case .push:
            guard let viewController = action.viewController else { break }
            viewControllers.append(viewController)
        case .pop:
            viewControllers.removeLast()
        case .presentModal:
            modalViewController = action.viewController
        case .dismissModal:
            modalViewController = nil
        }
        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: modalViewController)
        newState[action.navigationController] = navigationStackState
        return newState
    }

    static func reduceDismissModalAction(action: DismissModal, state: AppStackState) -> AppStackState {
        var newState = state
        var navigationStackState = state[action.navigationController] ?? NavigationStackState()
        let viewControllers = navigationStackState.viewControllers ?? [ViewController]()

        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
        newState[action.navigationController] = navigationStackState
        return newState
    }
}
