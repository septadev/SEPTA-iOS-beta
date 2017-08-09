// Septa. 2017

import Foundation
import ReSwift

protocol ScheduleAction: Action {}



struct ScheduleActions {

    struct TransitModeSelected: ScheduleAction {

        let transitMode: TransitMode
    }

    struct DisplayRoutes: ScheduleAction {}

   
}
