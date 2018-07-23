
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol TripDetailState_TripDetailsExistWatcherDelegate: AnyObject {
    func tripDetailState_TripDetailsExistUpdated(bool: Bool)
}

class TripDetailState_TripDetailsExistWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var delegate: TripDetailState_TripDetailsExistWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.tripDetailState.tripDetailsExist }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.tripDetailState_TripDetailsExistUpdated(bool: state)
    }
}
