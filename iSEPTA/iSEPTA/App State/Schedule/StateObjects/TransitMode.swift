// Septa. 2017

import Foundation

enum TransitMode: String, Codable {
    case bus
    case rail
    case subway
    case nhsl
    case trolley

    var routeTitle: String {
        switch self {
        case .bus: return "Bus Routes"
        case .rail: return "Regional Rail Routes"
        case .subway: return "Subway Routes"
        case .nhsl: return "NHSL Routes"
        case .trolley: return "Trolley Routes"
        }
    }


}
