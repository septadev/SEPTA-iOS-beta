// Septa. 2017

import Foundation

enum ViewController: String, Equatable {
    /// Initial screen in schedules.  Holds the toolbar. Root view controller
    case selectSchedules
    case routesViewController
    case selectStartController
    case selectStopController
    case selectStopNavigationController
    case tripScheduleController

    // -- next to arrive
    case nextToArriveSelectTrip

    func storyboardIdentifier() -> String {
        switch self {
        case .selectSchedules:
            return "schedules"
        case .routesViewController:
            return "schedules"
        case .selectStartController:
            return "schedules"
        case .selectStopController:
            return "schedules"
        case .selectStopNavigationController:
            return "schedules"
        case .tripScheduleController:
            return "schedules"

        case .nextToArriveSelectTrip:
            return "nextToArrive"
        }
    }
}
