// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class SchedulesNavigationController: UINavigationController, StoreSubscriber, IdentifiableNavController {
    static var navController: NavigationController = .schedules
    typealias StoreSubscriberStateType = [NavigationController: NavigationStackState]?
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    let showRoutesId = "showRoutes"
    let myStoryboard = UIStoryboard(name: navController.rawValue, bundle: Bundle.main)

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        initializeNavStackState()
        navigationBar.backgroundColor = UIColor.clear
    }

    func initializeNavStackState() {
        let navigationStackState = NavigationStackState(viewControllers: [.selectSchedules], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState, description: "Initialing schedule nav state")
        store.dispatch(action)
    }

    var currentStackState = NavigationStackState()
    func newState(state: StoreSubscriberStateType) {

        guard let newState = state, let newStackState = newState[.schedules], newStackState != currentStackState else { return }

        if let modal = newStackState.modalViewController {

            let viewController = myStoryboard.instantiateViewController(withIdentifier: modal.rawValue)
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = slideInTransitioningDelegate
            present(viewController, animated: true)
        }
        if let _ = currentStackState.modalViewController, newStackState.modalViewController == nil {
            dismiss(animated: true, completion: nil)
            slideInTransitioningDelegate = SlideInPresentationManager()
        }

        if let newViewControllers = newStackState.viewControllers,
            let lastNewViewController = newViewControllers.last {
            let uiControllersCount = viewControllers.count

            if uiControllersCount > newViewControllers.count {
                popViewController(animated: true)
            } else if uiControllersCount < newViewControllers.count {
                let newViewController = myStoryboard.instantiateViewController(withIdentifier: lastNewViewController.rawValue)
                pushViewController(newViewController, animated: true)
            }
        }

        currentStackState = newStackState
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.navigationState.appStackState
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
