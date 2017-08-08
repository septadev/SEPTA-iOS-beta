// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {

    let scheduleRequest: ScheduleRequest?
    let scheduleData: ScheduleData?
    let scheduleNavigation: FeatureViewControllerDisplayState?

    init(scheduleRequest: ScheduleRequest? = nil, scheduleData: ScheduleData? = nil, scheduleNavigation: FeatureViewControllerDisplayState? = nil) {
        self.scheduleRequest = scheduleRequest
        self.scheduleData = scheduleData
        self.scheduleNavigation = scheduleNavigation
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

    switch (lhs.scheduleData, rhs.scheduleData) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.scheduleData! == rhs.scheduleData!
    default:
        return false
    }

    switch (lhs.scheduleNavigation, rhs.scheduleNavigation) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.scheduleNavigation! == rhs.scheduleNavigation!
    default:
        return false
    }
    return areEqual
}
