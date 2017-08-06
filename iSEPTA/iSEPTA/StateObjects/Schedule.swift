// Septa. 2017

import Foundation

struct Schedule {
    let route: Int
    let name: String
    let start: String?
}

extension Schedule: Equatable {}
func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    return lhs.route == rhs.route &&
        lhs.name == rhs.name &&
        lhs.start == rhs.start
}
