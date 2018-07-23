
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol AlertState_HasGenericOrAppAlertsWatcherDelegate: AnyObject {
    func alertState_HasGenericOrAppAlertsUpdated(bool: Bool)
}

class AlertState_HasGenericOrAppAlertsWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var delegate: AlertState_HasGenericOrAppAlertsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.hasGenericOrAppAlerts }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_HasGenericOrAppAlertsUpdated(bool: state)
    }
}
