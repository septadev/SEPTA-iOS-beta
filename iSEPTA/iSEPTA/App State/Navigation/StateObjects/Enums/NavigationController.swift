// Septa. 2017

import Foundation

@objc enum NavigationController: Int {
    case nextToArrive
    case favorites
    case alerts
    case schedules
    case selectStop
    case fares

    func tabIndex() -> Int {
        switch self {
        case .nextToArrive: return 0
        case .favorites: return 1
        case .alerts : return 2
        case .schedules : return 3
        case .selectStop: return 3
        case .fares: return 4
        }
    }

    func storyboard() -> String {
        switch self {
        case .nextToArrive: return "nextToArrive"
        case .favorites: return "favorites"
        case .alerts : return "alerts"
        case .schedules : return "schedules"
        case .selectStop: return "schedules"
        case .fares: return "fares"
        }
    }
}
