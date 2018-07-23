
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol AlertState_HasGenericAlertsWatcherDelegate: AnyObject {
    func alertState_HasGenericAlertsUpdated(bool: Bool)
}

class AlertState_HasGenericAlertsWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var delegate: AlertState_HasGenericAlertsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.hasGenericAlerts }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_HasGenericAlertsUpdated(bool: state)
    }
}
