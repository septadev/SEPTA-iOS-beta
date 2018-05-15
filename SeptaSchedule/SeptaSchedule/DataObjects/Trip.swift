// Septa. 2017

import Foundation
// Encapsulates a trip
public struct Trip {
    public let tripId: String
    let departureInt: Int
    let arrivalInt: Int
    public let blockId: String

    public var departureComponents: DateComponents {
        return departureInt.toDataComponents()
    }

    public var arrivalComponents: DateComponents {
        return arrivalInt.toDataComponents()
    }

    public var departureDate: Date? {
        return Calendar.current.date(from: departureComponents)
    }

    public var arrivalDate: Date? {
        return Calendar.current.date(from: arrivalComponents)
    }

    public var tripDuration: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: departureComponents, to: arrivalComponents)
    }

    init(tripId: String, departureInt: Int, arrivalInt: Int, blockId: String) {
        self.departureInt = departureInt
        self.arrivalInt = arrivalInt
        self.blockId = blockId
        self.tripId = tripId
    }

    enum CodingKeys: String, CodingKey {
        case departureInt
        case arrivalInt
    }
}

extension Trip: Equatable {}
public func == (lhs: Trip, rhs: Trip) -> Bool {
    var areEqual = true

    areEqual = lhs.departureInt == rhs.departureInt
    guard areEqual else { return false }

    areEqual = lhs.arrivalInt == rhs.arrivalInt
    guard areEqual else { return false }

    areEqual = lhs.blockId == rhs.blockId
    guard areEqual else { return false }

    areEqual = lhs.tripId == rhs.tripId
    guard areEqual else { return false }

    return areEqual
}

private extension Int {

    func toDataComponents() -> DateComponents {

        let minute = self % 100
        let hour = (self - minute) / 100

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
}
