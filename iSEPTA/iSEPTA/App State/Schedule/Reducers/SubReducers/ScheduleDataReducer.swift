// Septa. 2017

import Foundation

struct ScheduleDataReducer {

    static func initScheduleData() -> ScheduleData {
        return ScheduleData()
    }

    static func reduceData(action _: ScheduleAction, scheduleData: ScheduleData) -> ScheduleData {
        return scheduleData
    }
}
