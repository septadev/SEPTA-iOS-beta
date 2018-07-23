
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol NextToArriveUpdateStatusWatcherDelegate: AnyObject {
    func nextToArriveUpdateStatusUpdated(nextToArriveUpdateStatus: NextToArriveUpdateStatus)
}

class NextToArriveState_NextToArriveUpdateStatusWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = NextToArriveUpdateStatus

    weak var delegate: NextToArriveUpdateStatusWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.nextToArriveUpdateStatus }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.nextToArriveUpdateStatusUpdated(nextToArriveUpdateStatus: state)
    }
}

class NextToArriveFavorite_NextToArriveUpdateStatusWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = NextToArriveUpdateStatus?

    weak var delegate: NextToArriveUpdateStatusWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.nextToArriveFavorite?.nextToArriveUpdateStatus }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let updateStatus = state else { return }
        delegate?.nextToArriveUpdateStatusUpdated(nextToArriveUpdateStatus: updateStatus)
    }
}
