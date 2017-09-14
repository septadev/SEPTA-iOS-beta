// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleDataProvider: BaseScheduleDataProvider {

    static let sharedInstance = ScheduleDataProvider()

    init() {
        super.init(targetForScheduleAction: .schedules)
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }.skipRepeats { $0 == $1 }
        }
        handleDefaultTransitMode()
    }

    func handleDefaultTransitMode() {
        let defaultScheduleRequest = ScheduleRequest()
        retrieveAvailableRoutes(scheduleRequest: defaultScheduleRequest)
    }
}
