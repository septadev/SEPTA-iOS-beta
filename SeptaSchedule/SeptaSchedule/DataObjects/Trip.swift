// SEPTA.org, created on 8/1/17.

import Foundation
// Encapsulates a trip
public struct Trip {
    
    let departureInt: Int
    let arrivalInt: Int

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
}

extension Trip: Equatable {
    public static func == (lhs: Trip, rhs: Trip) -> Bool {
        return
            lhs.departureInt == rhs.departureInt &&
            lhs.arrivalInt == rhs.arrivalInt
    }
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
