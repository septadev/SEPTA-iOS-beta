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
        let navigationStackState = NavigationStackState(viewControllers: [.selectSchedules], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .schedules, navigationStackState: navigationStackState)
        store.dispatch(action)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func filterSubscription(state: AppState) -> [NavigationController: NavigationStackState]? {
        return state.navigationState.appStackState
    }

    func newState(state: StoreSubscriberStateType) {

        guard let state = state, let stackState = state[.schedules] else { return }
        if let modal = stackState.modalViewController {
            let viewController = myStoryboard.instantiateViewController(withIdentifier: modal.rawValue)
            present(viewController, animated: true) {
                print("Just displayed the view controller")
            }
        }
    }
}
