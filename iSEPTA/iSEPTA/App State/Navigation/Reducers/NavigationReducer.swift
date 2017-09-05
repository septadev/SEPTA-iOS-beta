// Septa. 2017

import Foundation
import ReSwift

struct NavigationReducer {
    static func main(action: Action, state: NavigationState?) -> NavigationState {

        if let state = state {
            guard let action = action as? NavigationAction else { return state }

            return reduceNavigationActions(action: action, state: state)

        } else {
            return NavigationState()
        }
    }

    static func reduceNavigationActions(action: NavigationAction, state: NavigationState) -> NavigationState {

        var navigationState: NavigationState
        switch action {
        case let action as InitializeNavigationState:
            navigationState = reduceInitializeViewAction(action: action, state: state)
        case let action as SwitchTabs:
            navigationState = reduceSwitchTabsAction(action: action, state: state)
        case let action as PresentModal:
            navigationState = reducePresentModalAction(action: action, state: state)
        case let action as DismissModal:
            navigationState = reduceDismissModalAction(action: action, state: state)
        case let action as PushViewController:
            navigationState = reducePushViewControllerAction(action: action, state: state)
        case let action as UserPoppedViewController:
            navigationState = reduceUserPoppedViewControllerAction(action: action, state: state)

        default:
            navigationState = state
        }

        return navigationState
    }

    static func reduceSwitchTabsAction(action: SwitchTabs, state: NavigationState) -> NavigationState {
        return NavigationState(appStackState: state.appStackState, activeNavigationController: action.activeNavigationController)
    }

    static func reduceInitializeViewAction(action: InitializeNavigationState, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        appStackState[action.navigationController] = action.navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePresentModalAction(action: PresentModal, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        let viewControllers = navigationStackState.viewControllers ?? [ViewController]()

        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: action.viewController)
        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceDismissModalAction(action _: DismissModal, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        let viewControllers = navigationStackState.viewControllers ?? [ViewController]()

        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePushViewControllerAction(action: PushViewController, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        var viewControllers = navigationStackState.viewControllers ?? [ViewController]()
        viewControllers.append(action.viewController)
        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceUserPoppedViewControllerAction(action _: UserPoppedViewController, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        var viewControllers = navigationStackState.viewControllers ?? [ViewController]()
        viewControllers.removeLast()
        navigationStackState = NavigationStackState(viewControllers: viewControllers, modalViewController: nil)
        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }
}
