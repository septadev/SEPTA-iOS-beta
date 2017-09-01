// Septa. 2017

import Foundation

public enum ScheduleType: Int, Codable {
    case weekday = 1
    case saturday = 2
    case sunday = 3
    case friday = 4
    case mondayThroughThursday = 5

    public func stringForSegments() -> String {
        switch self {
        case .weekday: return "Weekday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        case .friday: return "Friday"
        case .mondayThroughThursday: return "Mon-Thur"
        }
    }
}
