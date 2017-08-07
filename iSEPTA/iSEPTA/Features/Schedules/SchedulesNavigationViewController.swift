// Septa. 2017

import Foundation
import UIKit
import ReSwift

class SchedulesNavigationController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationState

    override func viewDidLoad() {
        super.viewDidLoad()
        store.dispatch(ScheduleActions.WillViewSchedules())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.dispatch(SwitchFeatureCompleted(activeFeature: .schedules))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func filterSubscription(state: AppState) -> NavigationState {
        return state.navigationState
    }

    func newState(state _: StoreSubscriberStateType) {
    }
}
