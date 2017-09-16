
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol ScheduleState_ScheduleRequestWatcherDelegate: AnyObject {
    func scheduleState_ScheduleRequestUpdated(scheduleRequest: ScheduleRequest)
}

class ScheduleState_ScheduleRequestWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: ScheduleState_ScheduleRequestWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.scheduleState_ScheduleRequestUpdated(scheduleRequest: state)
    }
}
