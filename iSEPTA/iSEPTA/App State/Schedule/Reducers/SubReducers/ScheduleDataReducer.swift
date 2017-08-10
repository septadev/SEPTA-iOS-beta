// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleDataReducer {

    static func initScheduleData() -> ScheduleData {
        return ScheduleData()
    }

    static func reduceData(action: ScheduleAction, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        switch action {
        case _ as TransitModeSelected:
            newScheduleData = ScheduleData()

        case let action as RoutesLoaded:
            newScheduleData = reduceRoutesLoaded(action: action, scheduleData: newScheduleData)
        default: break
        }
        return newScheduleData
    }

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: action.routes,
                                        availableStarts: nil,
                                        availableStops: nil,
                                        availableTrips: nil,
                                        errorString: action.error?.localizedDescription)
        return scheduleData
    }
}
