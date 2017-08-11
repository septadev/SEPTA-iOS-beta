// Septa. 2017

import Foundation
import UIKit
import ReSwift

class SchedulesNavigationController: UINavigationController, StoreSubscriber, IdentifiableNavController {
    static var navController: NavigationController = .schedules
    typealias StoreSubscriberStateType = [NavigationController: NavigationStackState]?

    let showRoutesId = "showRoutes"
    let myStoryboard = UIStoryboard(name: navController.rawValue, bundle: Bundle.main)

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        initializeNavStackState()
    }

    func initializeNavStackState() {
        let navigationStackState = NavigationStackState(viewControllers: [.selectSchedules], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState, description: "Initialing schedule nav state")
        store.dispatch(action)
    }

    func filterSubscription(state: AppState) -> [NavigationController: NavigationStackState]? {
        return state.navigationState.appStackState
    }

    var lastStackState = NavigationStackState()
    func newState(state: StoreSubscriberStateType) {

        guard let newState = state, let newStackState = newState[.schedules], newStackState != lastStackState else { return }

        if let modal = newStackState.modalViewController {
            let viewController = myStoryboard.instantiateViewController(withIdentifier: modal.rawValue)
            present(viewController, animated: true)
        }
        if let existingModal = lastStackState.modalViewController, newStackState.modalViewController == nil {
            dismiss(animated: true, completion: nil)
        }

        lastStackState = newStackState
    }

    func subscribe() {

        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
