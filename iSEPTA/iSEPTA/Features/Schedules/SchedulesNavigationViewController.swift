// Septa. 2017

import Foundation
import UIKit
import ReSwift

class SchedulesNavigationController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = [NavigationController]?

    let showRoutesId = "showRoutes"

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func filterSubscription(state: AppState) -> [NavigationController]? {
        return state.navigationState.navigationControllers
    }

    func newState(state _: StoreSubscriberStateType) {
    }
}
