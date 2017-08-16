// Septa. 2017

import Foundation

public enum TransitMode: String {
    case bus
    case rail
    case subway
    case nhsl
    case trolley

    public func routeTitle() -> String {
        switch self {
        case .bus: return "Bus Route"
        case .rail: return "Rail Line"
        case .subway: return "Subway Line"
        case .nhsl: return "NHSL Line"
        case .trolley: return "Trolley Line"
        }
    }
}
