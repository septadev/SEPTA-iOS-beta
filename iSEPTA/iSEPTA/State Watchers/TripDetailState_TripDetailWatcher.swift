
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol TripDetailState_TripDetailsWatcherDelegate: AnyObject {
    func tripDetailState_TripDetailsUpdated(nextToArriveStop: NextToArriveStop)
}

class TripDetailState_TripDetailsWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = NextToArriveStop?

    weak var delegate: TripDetailState_TripDetailsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.tripDetailState.tripDetails }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let tripDetails = state else { return }
        delegate?.tripDetailState_TripDetailsUpdated(nextToArriveStop: tripDetails)
    }
}
