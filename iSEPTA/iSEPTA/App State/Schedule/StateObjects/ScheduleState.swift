// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {

    let scheduleRequest: ScheduleRequest
    let scheduleData: ScheduleData
    let scheduleStopEdit: ScheduleStopEdit

    init(scheduleRequest: ScheduleRequest = ScheduleRequest(), scheduleData: ScheduleData = ScheduleData(), scheduleStopEdit: ScheduleStopEdit = ScheduleStopEdit()) {
        self.scheduleRequest = scheduleRequest
        self.scheduleData = scheduleData
        self.scheduleStopEdit = scheduleStopEdit
    }
}

extension ScheduleState: Equatable {}
func == (lhs: ScheduleState, rhs: ScheduleState) -> Bool {
    var areEqual = true

    areEqual = lhs.scheduleRequest == rhs.scheduleRequest
    guard areEqual else { return false }

    areEqual = lhs.scheduleData == rhs.scheduleData
    guard areEqual else { return false }

    areEqual = lhs.scheduleStopEdit == rhs.scheduleStopEdit
    guard areEqual else { return false }

    return areEqual
}
