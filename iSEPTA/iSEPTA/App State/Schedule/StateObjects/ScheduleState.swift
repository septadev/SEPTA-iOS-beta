// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleState {

    let scheduleRequest: ScheduleRequest
    let scheduleData: ScheduleData
    let scheduleStopEdit: ScheduleStopEdit
    let databaseIsLoaded: Bool

    init(scheduleRequest: ScheduleRequest = ScheduleRequest(), scheduleData: ScheduleData = ScheduleData(), scheduleStopEdit: ScheduleStopEdit = ScheduleStopEdit(), databaseIsLoaded: Bool = false) {
        self.scheduleRequest = scheduleRequest
        self.scheduleData = scheduleData
        self.scheduleStopEdit = scheduleStopEdit
        self.databaseIsLoaded = databaseIsLoaded
    }
}

extension ScheduleState: Equatable {}
func ==(lhs: ScheduleState, rhs: ScheduleState) -> Bool {
    var areEqual = true

    areEqual = lhs.scheduleRequest == rhs.scheduleRequest
    guard areEqual else { return false }

    areEqual = lhs.scheduleData == rhs.scheduleData
    guard areEqual else { return false }

    areEqual = lhs.scheduleStopEdit == rhs.scheduleStopEdit
    guard areEqual else { return false }

    areEqual = lhs.databaseIsLoaded == rhs.databaseIsLoaded
    guard areEqual else { return false }

    return areEqual
}
