// Septa. 2017

import Foundation

enum TransitMode {
    case bus

    var routeTitle: String {
        switch self {
        case .bus: return "Bus Routes"
        }
    }
}
