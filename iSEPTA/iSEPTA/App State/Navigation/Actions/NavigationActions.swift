// Septa. 2017

import Foundation
import ReSwift

protocol NavigationAction: SeptaAction {}

struct InitializeNavigationState: NavigationAction {
    let navigationController: NavigationController
    let navigationStackState: NavigationStackState
    let description: String
}

struct TransitionView: NavigationAction {
    let navigationController: NavigationController
    let viewController: ViewController?
    let viewTransitionType: ViewTransitionType
    let description: String
}

struct SwitchTabs: NavigationAction {
    let tabBarItemIndex: NavigationController
    let description: String
}

struct DismissModal: NavigationAction {
    let navigationController: NavigationController
    let description: String
}

struct PresentModal: NavigationAction {
    let navigationController: NavigationController
    let viewController: ViewController
    let description: String
}

struct PushViewController: NavigationAction {
    let navigationController: NavigationController
    let viewController: ViewController
    let description: String
}

struct UserPoppedViewController: NavigationAction {
    let navigationController: NavigationController
    let description: String
}
