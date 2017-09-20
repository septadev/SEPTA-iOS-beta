
// Septa. 2017

import SeptaSchedule
import ReSwift

class NextToArriveState_ScheduleState_ScheduleRequestWatcher: BaseScheduleRequestWatcher {

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }
        }
    }
}
