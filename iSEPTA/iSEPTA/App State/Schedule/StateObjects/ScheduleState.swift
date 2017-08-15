// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {

    let scheduleRequest: ScheduleRequest?
    let scheduleData: ScheduleData?

    init(scheduleRequest: ScheduleRequest? = nil, scheduleData: ScheduleData? = nil) {
        self.scheduleRequest = scheduleRequest
        self.scheduleData = scheduleData
    }
}

extension ScheduleState: Equatable {}
func ==(lhs: ScheduleState, rhs: ScheduleState) -> Bool {
    var areEqual = true

    switch (lhs.scheduleRequest, rhs.scheduleRequest) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.scheduleRequest! == rhs.scheduleRequest!
    default:
        return false
    }
    guard areEqual else { return false }

    switch (lhs.scheduleData, rhs.scheduleData) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.scheduleData! == rhs.scheduleData!
    default:
        return false
    }
    guard areEqual else { return false }

    return areEqual
}
