// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {

    let scheduleRequest: ScheduleRequest?
    let scheduleData: ScheduleData?
    let scheduleStopEdit: ScheduleStopEdit?

    init(scheduleRequest: ScheduleRequest? = nil, scheduleData: ScheduleData? = nil, scheduleStopEdit: ScheduleStopEdit? = nil) {
        self.scheduleRequest = scheduleRequest
        self.scheduleData = scheduleData
        self.scheduleStopEdit = scheduleStopEdit
    }
}

extension ScheduleState: Equatable {}
func ==(lhs: ScheduleState, rhs: ScheduleState) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.scheduleRequest, newValue: rhs.scheduleRequest).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.scheduleData, newValue: rhs.scheduleData).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.scheduleStopEdit, newValue: rhs.scheduleStopEdit).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
