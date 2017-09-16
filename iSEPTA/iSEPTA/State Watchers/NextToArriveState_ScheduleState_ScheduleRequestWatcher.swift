
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol NextToArriveState_ScheduleState_ScheduleRequestWatcherDelegate: AnyObject {
    func nextToArriveState_ScheduleState_ScheduleRequestUpdated(scheduleRequest: ScheduleRequest)
}

class NextToArriveState_ScheduleState_ScheduleRequestWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: NextToArriveState_ScheduleState_ScheduleRequestWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.nextToArriveState_ScheduleState_ScheduleRequestUpdated(scheduleRequest: state)
    }
}
