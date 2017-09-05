// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

class RoutesViewModel: BaseRoutesViewModel {
    override func awakeFromNib() {

        if let targetForRouteUpdates = determineTargetForRouteUpdates() {
            super.targetForScheduleAction = targetForRouteUpdates
        }
        super.awakeFromNib()
    }

    func determineTargetForRouteUpdates() -> TargetForScheduleAction? {
        let scheduleTargets: [NavigationController] = [.nextToArrive, .schedules]
        let activeNavigationController = store.state.navigationState.activeNavigationController
        guard scheduleTargets.contains(activeNavigationController) else { return nil }

        if activeNavigationController == .schedules { return TargetForScheduleAction.schedules }
        if activeNavigationController == .nextToArrive { return TargetForScheduleAction.nextToArrive }
        return nil
    }

    override func subscribe() {
        if super.targetForScheduleAction == .schedules {
            store.subscribe(self) {
                $0.select { $0.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        } else if super.targetForScheduleAction == .nextToArrive {
            store.subscribe(self) {
                $0.select { $0.nextToArriveState.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        }
    }
}
