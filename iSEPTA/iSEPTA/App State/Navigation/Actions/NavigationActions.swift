// Septa. 2017

import Foundation
import ReSwift
import UIKit

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
    let activeNavigationController: NavigationController
    let description: String
}

struct DismissModal: NavigationAction {
    let description: String
}

struct PresentModal: NavigationAction {
    let viewController: ViewController
    let description: String
}

struct PushViewController: NavigationAction {
    let viewController: ViewController
    let description: String
}

struct PushNonActiveViewController: NavigationAction {
    let navigationController: NavigationController
    let viewController: ViewController
    let description: String
}

struct UserPoppedViewController: NavigationAction {
    let viewController: ViewController
    let description: String
}

struct PopViewController: NavigationAction {
    let viewController: ViewController
    let description: String
}
