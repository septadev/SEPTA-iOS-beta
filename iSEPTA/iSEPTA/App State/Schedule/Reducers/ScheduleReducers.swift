// Septa. 2017

import Foundation
import ReSwift

class ScheduleReducers {

    class func main(action: Action, state: ScheduleState?) -> ScheduleState {
        let scheduleState = state ?? ScheduleState()
        guard let scheduleAction = action as? ScheduleAction else { return scheduleState }


        return ScheduleState(
            scheduleRequest: scheduleRequest(scheduleAction: scheduleAction, scheduleState: scheduleState),
            scheduleData: scheduleData(scheduleAction: scheduleAction, scheduleState: scheduleState),
            scheduleNavigation: scheduleNavigation(scheduleAction: scheduleAction, scheduleState: scheduleState)
        )
    }

    class func scheduleRequest(scheduleAction: ScheduleAction, scheduleState: ScheduleState?) -> ScheduleRequest   {
        return ScheduleRequest()
    }

    class func scheduleData(scheduleAction: ScheduleAction, scheduleState: ScheduleState?) -> ScheduleData{
        return ScheduleData()
    }

    class func scheduleNavigation(scheduleAction: ScheduleAction, scheduleState: ScheduleState) -> FeatureViewControllerDisplayState{
        return FeatureViewControllerDisplayState()
    }

}
