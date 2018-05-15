
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol AlertState_HasAppAlertsWatcherDelegate: AnyObject {
    func alertState_HasAppAlertsUpdated(bool: Bool)
}

class AlertState_HasAppAlertsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = Bool

    weak var delegate: AlertState_HasAppAlertsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.hasAppAlerts }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_HasAppAlertsUpdated(bool: state)
    }
}
