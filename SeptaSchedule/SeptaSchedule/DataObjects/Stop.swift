// SEPTA.org, created on 7/31/17.

import Foundation

public struct Stop {
    public let stopId: Int
    public let stopName: String
    public let stopLatitude: Double
    public let stopLongitude: Double
    public let wheelchairBoarding: Bool
}

extension Stop: Equatable {
    public static func == (lhs: Stop, rhs: Stop) -> Bool {
        return
            lhs.stopId == rhs.stopId &&
            lhs.stopName == rhs.stopName &&
            GeoCompare.point(lhs.stopLatitude, rhs.stopLatitude) &&
            GeoCompare.point(lhs.stopLongitude, rhs.stopLongitude) &&
            lhs.wheelchairBoarding == rhs.wheelchairBoarding
    }
}
