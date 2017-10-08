
// Septa. 2017

import SeptaSchedule
import ReSwift
import SeptaRest

protocol AlertState_GenericAlertDetailsWatcherDelegate: AnyObject {
    func alertState_GenericAlertDetailsUpdated(alertDetails: [AlertDetails_Alert])
}

class AlertState_GenericAlertDetailsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = [AlertDetails_Alert]

    weak var delegate: AlertState_GenericAlertDetailsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.genericAlertDetails }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_GenericAlertDetailsUpdated(alertDetails: state)
    }
}
