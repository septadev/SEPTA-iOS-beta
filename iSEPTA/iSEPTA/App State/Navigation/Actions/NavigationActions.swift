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

struct ResetViewState: NavigationAction, Equatable {
    let viewController: ViewController
    let description: String
}

struct ResetViewStateHandled: NavigationAction, Equatable {
    let description = "Navigation View State has been reset"
}

struct AddAlertToDisplay: NavigationAction, Equatable {
    let description = "Adding a global Alert to Display"
    let appAlert: AppAlert
}

struct CurrentAppAlertDismissed: NavigationAction, Equatable {
    let description = "Just Dismissed an App Alert"
}

