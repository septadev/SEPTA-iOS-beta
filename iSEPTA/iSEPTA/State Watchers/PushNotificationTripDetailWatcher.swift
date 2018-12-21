// Septa. 2018

import SeptaSchedule
import ReSwift

protocol PushNotificationTripDetailState_TripIdWatcherDelegate: AnyObject {
    func pushNotificationTripDetailState_TripIdUpdated(tripId: String?)
}

class PushNotificationTripDetailState_TripIdWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = String?

    weak var delegate: PushNotificationTripDetailState_TripIdWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    private func subscribe() {
        store.subscribe(self) {
            $0.select { $0.pushNotificationTripDetailState.tripId}
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.pushNotificationTripDetailState_TripIdUpdated(tripId: state )
    }
}




