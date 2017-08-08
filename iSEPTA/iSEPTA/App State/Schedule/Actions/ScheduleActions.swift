// Septa. 2017

import Foundation
import ReSwift

protocol ScheduleAction: Action {}

class ScheduleActions {
    struct WillViewSchedules: ScheduleAction {
    }

    struct TransitModeSelected: ScheduleAction {

        let transitMode: TransitMode
    }

    struct TransitModeDisplayed: ScheduleAction {
        let transitMode: TransitMode?
    }
}
