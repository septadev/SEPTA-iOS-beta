
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol NextToArriveState_ScheduleState_ScheduleRequestWatcherDelegate: AnyObject {
    func stateUpdated(scheduleRequest: ScheduleRequest)
}

class NextToArriveState_ScheduleState_ScheduleRequestWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: NextToArriveState_ScheduleState_ScheduleRequestWatcherDelegate?

    init(delegate: NextToArriveState_ScheduleState_ScheduleRequestWatcherDelegate) {
        self.delegate = delegate
        super.init()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.stateUpdated(scheduleRequest: state)
    }
}
