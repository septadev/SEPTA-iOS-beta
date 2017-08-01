// SEPTA.org, created on 7/31/17.

import Foundation

struct Stop {
    let stopId: Int
    let stopName: String
    let stopLatitude: Double
    let stopLongitude: Double
    let wheelchairBoarding: Bool
}

extension Stop: Equatable {
    static func == (lhs: Stop, rhs: Stop) -> Bool {
        return
            lhs.stopId == rhs.stopId &&
            lhs.stopName == rhs.stopName &&
            GeoCompare.point(lhs.stopLatitude, rhs.stopLatitude) &&
            GeoCompare.point(lhs.stopLongitude, rhs.stopLongitude) &&
            lhs.wheelchairBoarding == rhs.wheelchairBoarding
    }
}
