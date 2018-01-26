
// Septa. 2017

import ReSwift
import SeptaRest
import SeptaSchedule

protocol AlertState_AppAlertDetailsWatcherDelegate: AnyObject {
    func alertState_AppAlertDetailsUpdated(alertDetails: [AlertDetails_Alert])
}

class AlertState_AppAlertDetailsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = [AlertDetails_Alert]

    weak var delegate: AlertState_AppAlertDetailsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.appAlertDetails }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_AppAlertDetailsUpdated(alertDetails: state)
    }
}
