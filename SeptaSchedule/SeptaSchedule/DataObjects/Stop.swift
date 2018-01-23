// Septa. 2017

import Foundation

public struct Stop: Codable {
    public let stopId: Int
    public let stopName: String
    public let stopLatitude: Double
    public let stopLongitude: Double
    public let wheelchairBoarding: Bool
    public let weekdayService: Bool
    public let saturdayService: Bool
    public let sundayService: Bool

    public init(stopId: Int, stopName: String, stopLatitude: Double, stopLongitude: Double, wheelchairBoarding: Bool, weekdayService: Bool, saturdayService: Bool, sundayService: Bool) {
        self.stopId = stopId
        self.stopName = stopName
        self.stopLatitude = stopLatitude
        self.stopLongitude = stopLongitude
        self.wheelchairBoarding = wheelchairBoarding
        self.weekdayService = weekdayService
        self.saturdayService = saturdayService
        self.sundayService = sundayService
    }

    enum CodingKeys: String, CodingKey {
        case stopId
        case stopName
        case stopLatitude
        case stopLongitude
        case wheelchairBoarding
        case weekdayService
        case saturdayService
        case sundayService
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
        stopId = try container.decode(Int.self, forKey: .stopId) // extracting the data
        stopName = try container.decode(String.self, forKey: .stopName) // extracting the data
        stopLatitude = try container.decode(Double.self, forKey: .stopLatitude) // extracting the data
        stopLongitude = try container.decode(Double.self, forKey: .stopLongitude)
        let wheelchairBoardingInt = try container.decode(Int.self, forKey: .wheelchairBoarding)
        wheelchairBoarding = wheelchairBoardingInt == 1
        let weekdayServiceInt = try container.decode(Int.self, forKey: .weekdayService)
        weekdayService = weekdayServiceInt == 1
        let saturdayServiceInt = try container.decode(Int.self, forKey: .saturdayService)
        saturdayService = saturdayServiceInt == 1
        let sundayServiceInt = try container.decode(Int.self, forKey: .sundayService)
        sundayService = sundayServiceInt == 1
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stopId, forKey: .stopId)
        try container.encode(stopName, forKey: .stopName)
        try container.encode(stopLatitude, forKey: .stopLatitude)
        try container.encode(stopLongitude, forKey: .stopLongitude)
        try container.encode(wheelchairBoarding ? 1 : 0, forKey: .wheelchairBoarding)
        try container.encode(weekdayService ? 1 : 0, forKey: .weekdayService)
        try container.encode(saturdayService ? 1 : 0, forKey: .saturdayService)
        try container.encode(sundayService ? 1 : 0, forKey: .sundayService)
    }
}

extension Stop: Hashable {
    public var hashValue: Int {
        return stopId.hashValue
    }
}

extension Stop: Equatable {}
public func == (lhs: Stop, rhs: Stop) -> Bool {
    var areEqual = true

    if lhs.stopId == rhs.stopId {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.stopName == rhs.stopName {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.stopLatitude == rhs.stopLatitude {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.stopLongitude == rhs.stopLongitude {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.wheelchairBoarding == rhs.wheelchairBoarding {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.weekdayService == rhs.weekdayService {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.saturdayService == rhs.saturdayService {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.sundayService == rhs.sundayService {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    return areEqual
}
