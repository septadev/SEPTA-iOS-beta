// Septa. 2017

import Foundation
import ReSwift
import UIKit

protocol NavigationAction: SeptaAction {}

// struct InitializeNavigationState: NavigationAction {
//    let navigationController: NavigationController
//    let navigationStackState: NavigationStackState
//    let description: String
// }

struct SwitchTabs: NavigationAction {
    let activeNavigationController: NavigationController
    let description: String
}

struct DismissModal: NavigationAction, Equatable {
    let description: String
}

struct DismissModalHandled: NavigationAction, Equatable {
    let description = "Navigation Controller Has Dismissed Modal"
}

struct PresentModal: NavigationAction, Equatable {
    let viewController: ViewController
    let description: String
}

struct PresentModalHandled: NavigationAction, Equatable {
    let description = "Navigation Controller Has Presented Modal"
}

struct PushViewController: NavigationAction, Equatable {
    let viewController: ViewController
    let description: String
}

struct PushViewControllerHandled: NavigationAction, Equatable {
    let description = "Navigation Controller Has Pushed Controller"
}

struct PopViewController: NavigationAction, Equatable {
    let viewController: ViewController
    let description: String
}

struct PopViewControllerHandled: NavigationAction, Equatable {
    let description = "Navigation Controller Has Popped Controller"
}
