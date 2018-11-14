
// Septa. 2018

import SeptaSchedule
import ReSwift

protocol PushNotificationTripDetailState_PushNotificationTripDetailDataWatcherDelegate: AnyObject {
    func pushNotificationTripDetailState_PushNotificationTripDetailDataUpdated(pushNotificationTripDetailData: PushNotificationTripDetailData?)
}

class PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = PushNotificationTripDetailData?

    weak var delegate: PushNotificationTripDetailState_PushNotificationTripDetailDataWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

   

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.pushNotificationTripDetailState.pushNotificationTripDetailData}
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.pushNotificationTripDetailState_PushNotificationTripDetailDataUpdated(pushNotificationTripDetailData: state )
    }
}


