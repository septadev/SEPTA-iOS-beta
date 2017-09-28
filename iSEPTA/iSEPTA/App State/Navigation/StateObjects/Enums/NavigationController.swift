// Septa. 2017

import Foundation

@objc enum NavigationController: Int {
    case nextToArrive
    case favorites
    case alerts
    case schedules
    case selectStop
    case more

    func tabIndex() -> Int {
        switch self {
        case .nextToArrive: return 0
        case .favorites: return 1
        case .alerts : return 2
        case .schedules : return 3
        case .selectStop: return 3
        case .more: return 4
        }
    }

    func storyboard() -> String {
        switch self {
        case .nextToArrive: return "nextToArrive"
        case .favorites: return "favorites"
        case .alerts : return "alerts"
        case .schedules : return "schedules"
        case .selectStop: return "schedules"
        case .more: return "more"
        }
    }
}
