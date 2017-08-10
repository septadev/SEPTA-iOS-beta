// Septa. 2017

import Foundation
import ReSwift

protocol NavigationAction: Action {}

struct InitializeNavigationState: NavigationAction {
    let navigationController: NavigationController
    let navigationStackState: NavigationStackState
}

struct TransitionView: NavigationAction {
    let navigationController: NavigationController
    let viewController: ViewController?
    let viewTransitionType: ViewTransitionType
}

struct SwitchTabs: NavigationAction {
    let tabBarItemIndex: Int
}
