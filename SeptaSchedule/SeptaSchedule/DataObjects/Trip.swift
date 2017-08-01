// SEPTA.org, created on 8/1/17.

import Foundation

struct Trip {
    let departureInt: Int
    let arrivalInt: Int
}

extension Trip: Equatable {
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return
            lhs.departureInt == rhs.departureInt &&
            lhs.arrivalInt == rhs.arrivalInt
    }
}
