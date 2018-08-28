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
        case let action as SwitchTabs:
            navigationState = reduceSwitchTabsAction(action: action, state: state)
        case let action as PresentModal:
            navigationState = reducePresentModal(action: action, state: state)
        case let action as DismissModal:
            navigationState = reduceDismissModal(action: action, state: state)
        case let action as PushViewController:
            navigationState = reducePushViewController(action: action, state: state)
        case let action as PopViewController:
            navigationState = reducePopViewController(action: action, state: state)
        case let action as PresentModalHandled:
            navigationState = reducePresentModalHandled(action: action, state: state)
        case let action as DismissModalHandled:
            navigationState = reduceDismissModalHandled(action: action, state: state)
        case let action as PushViewControllerHandled:
            navigationState = reducePushViewControllerHandled(action: action, state: state)
        case let action as PopViewControllerHandled:
            navigationState = reducePopViewControllerHandled(action: action, state: state)
        case let action as ResetViewState:
            navigationState = reduceResetViewState(action: action, state: state)
        case let action as ResetViewStateHandled:
            navigationState = reduceResetViewStateHandled(action: action, state: state)
        default:
            navigationState = state
        }

        return navigationState
    }

    static func reduceSwitchTabsAction(action: SwitchTabs, state: NavigationState) -> NavigationState {
        return NavigationState(appStackState: state.appStackState, activeNavigationController: action.activeNavigationController)
    }

    static func reducePresentModal(action: PresentModal, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.presentModal = action

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceDismissModal(action: DismissModal, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.dismissModal = action

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePushViewController(action: PushViewController, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.pushViewController = action

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePopViewController(action: PopViewController, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.popViewController = action

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePresentModalHandled(action _: PresentModalHandled, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.presentModal = nil

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceDismissModalHandled(action _: DismissModalHandled, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.dismissModal = nil

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePushViewControllerHandled(action _: PushViewControllerHandled, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.pushViewController = nil

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reducePopViewControllerHandled(action _: PopViewControllerHandled, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.popViewController = nil

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceResetViewState(action: ResetViewState, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.resetViewState = action

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }

    static func reduceResetViewStateHandled(action _: ResetViewStateHandled, state: NavigationState) -> NavigationState {
        var appStackState = state.appStackState
        let navigationController = store.state.navigationState.activeNavigationController
        var navigationStackState = appStackState[navigationController] ?? NavigationStackState()
        navigationStackState.resetViewState = nil

        appStackState[navigationController] = navigationStackState
        return NavigationState(appStackState: appStackState, activeNavigationController: state.activeNavigationController)
    }
}
