
// Septa. 2017

import ReSwift
import SeptaSchedule

class NextToArriveState_ScheduleState_ScheduleRequestWatcher: BaseScheduleRequestWatcher {
    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }
        }
    }
}
