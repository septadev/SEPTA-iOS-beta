
// Septa. 2017

import ReSwift
import SeptaSchedule

class ScheduleState_ScheduleRequestWatcher: BaseScheduleRequestWatcher {
    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }
        }
    }
}
