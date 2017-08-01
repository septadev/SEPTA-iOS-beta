// SEPTA.org, created on 8/1/17.

import Foundation

enum TransitMode {
    case bus

    var routeTitle: String {
        switch self {
        case .bus: return "Bus Routes"
        }
    }
}
