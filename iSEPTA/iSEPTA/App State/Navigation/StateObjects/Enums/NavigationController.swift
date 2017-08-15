// Septa. 2017

import Foundation

enum NavigationController: String, Codable {
    case nextToArrive
    case favorites
    case schedules
    case selectStop

    func tabIndex() -> Int {
        switch self {
        case .nextToArrive: return 0
        case .favorites: return 1
        case .schedules : return 2
        default:
            return 0
        }
    }
}
