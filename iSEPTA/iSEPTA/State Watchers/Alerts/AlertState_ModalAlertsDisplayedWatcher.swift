
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol AlertState_ModalAlertsDisplayedWatcherDelegate: AnyObject {
    func alertState_ModalAlertsDisplayedUpdated(modalAlertsDisplayed: Bool)
}

class AlertState_ModalAlertsDisplayedWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var delegate: AlertState_ModalAlertsDisplayedWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.modalAlertsDisplayed }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_ModalAlertsDisplayedUpdated(modalAlertsDisplayed: state)
    }
}
