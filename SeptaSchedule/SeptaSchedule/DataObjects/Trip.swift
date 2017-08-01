// SEPTA.org, created on 8/1/17.

import Foundation

public struct Trip {
    let departureInt: Int
    let arrivalInt: Int

    var departureComponents: DateComponents {
        return departureInt.toDataComponents()
    }

    var arrivalComponents: DateComponents {
        return arrivalInt.toDataComponents()
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
