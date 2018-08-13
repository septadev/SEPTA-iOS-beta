import Foundation
import ReSwift
import SeptaSchedule

class AlertScheduleDataProvider: BaseScheduleDataProvider {
    static let sharedInstance = AlertScheduleDataProvider()

    init() {
        super.init(targetForScheduleAction: .alerts)
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.scheduleState.scheduleRequest }.skipRepeats { $0 == $1 }
        }
    }

    override func processSelectedRoute(scheduleRequest: ScheduleRequest) {
        let routes = store.state.alertState.scheduleState.scheduleData.availableRoutes.routes
        if routes.count == 0 {
            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
        }
    }

    deinit {
        print("Next to arrive schedule data provider will vanish")
    }
}
