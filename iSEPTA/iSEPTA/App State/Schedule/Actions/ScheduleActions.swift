// Septa. 2017

import Foundation
import ReSwift

protocol ScheduleAction: Action {}

struct ScheduleActions {
    struct WillViewSchedules: ScheduleAction, Codable {
    }

    struct TransitModeSelected: ScheduleAction {

        let transitMode: TransitMode
    }

    struct TransitModeDisplayed: ScheduleAction, Codable {
        let transitMode: TransitMode?
    }
}
