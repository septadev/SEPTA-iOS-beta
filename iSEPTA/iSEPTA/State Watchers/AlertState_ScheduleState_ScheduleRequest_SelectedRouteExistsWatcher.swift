
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol AlertState_ScheduleState_ScheduleRequest_SelectedRouteExistsWatcherDelegate: AnyObject {
    func alertState_ScheduleState_ScheduleRequest_SelectedRouteExistsUpdated(bool: Bool)
}

class AlertState_ScheduleState_ScheduleRequest_SelectedRouteExistsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = Bool

    weak var delegate: AlertState_ScheduleState_ScheduleRequest_SelectedRouteExistsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.scheduleState.scheduleRequest.selectedRouteExists }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_ScheduleState_ScheduleRequest_SelectedRouteExistsUpdated(bool: state)
    }
}
