// Septa. 2017

import Foundation

public struct Stop: Codable {
    public let stopId: Int
    public let stopName: String
    public let stopLatitude: Double
    public let stopLongitude: Double
    public let wheelchairBoarding: Bool

    public init(stopId: Int, stopName: String, stopLatitude: Double, stopLongitude: Double, wheelchairBoarding: Bool) {
        self.stopId = stopId
        self.stopName = stopName
        self.stopLatitude = stopLatitude
        self.stopLongitude = stopLongitude
        self.wheelchairBoarding = wheelchairBoarding
    }
}

extension Stop: Equatable {}
public func ==(lhs: Stop, rhs: Stop) -> Bool {
    var areEqual = true

    if lhs.stopId == rhs.stopId {
        areEqual = true
    } else {
        return false
    }

    if lhs.stopName == rhs.stopName {
        areEqual = true
    } else {
        return false
    }

    if lhs.stopLatitude == rhs.stopLatitude {
        areEqual = true
    } else {
        return false
    }

    if lhs.stopLongitude == rhs.stopLongitude {
        areEqual = true
    } else {
        return false
    }

    if lhs.wheelchairBoarding == rhs.wheelchairBoarding {
        areEqual = true
    } else {
        return false
    }
    return areEqual
}
