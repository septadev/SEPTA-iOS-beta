
import Foundation

let calendar = Calendar.current

struct DaysOfWeek: OptionSet, Codable, Equatable {
    let rawValue: Int
    static let unknown = DaysOfWeek(rawValue: 0 << 0)
    static let monday = DaysOfWeek(rawValue: 1 << 0)
    static let tuesday = DaysOfWeek(rawValue: 1 << 1)
    static let wednesday = DaysOfWeek(rawValue: 1 << 2)
    static let thursday = DaysOfWeek(rawValue: 1 << 3)
    static let friday = DaysOfWeek(rawValue: 1 << 4)
    static let saturday = DaysOfWeek(rawValue: 1 << 5)
    static let sunday = DaysOfWeek(rawValue: 1 << 6)

    func matchesDate(_ date: Date) -> Bool {
        let filteredComponents = Calendar.current.dateComponents([.weekday], from: date)
        guard let weekday = filteredComponents.weekday else { return false }
        let dayOfWeek = DaysOfWeek.fromWeekdayComponent(weekday: weekday)
        return contains(dayOfWeek)
    }

    private static func fromWeekdayComponent(weekday: Int) -> DaysOfWeek {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .unknown
        }
    }
}

struct PeriodOfDay: Codable, Equatable {
    let startHour: Int
    let endHour: Int
}

let range = 0 ..< 6
print(range.contains(6))

let dateFormatter = DateFormatter()
dateFormatter.timeStyle = .short
dateFormatter.dateStyle = .short

let now = Date()
let oneHourAgo = now - 60 * 60
let oneHourFromNow = now + 60 * 60

let minuteOfDayComponentUnits: Set<Calendar.Component> = [.hour, .minute]

/// Extracts the hour and minutes from a given date.
func truncateDateToMinuteOfDayComponents(date: Date) -> DateComponents {
    return calendar.dateComponents(minuteOfDayComponentUnits, from: date)
}

/// Calculate the total number of minutes since midnight.
func calculateMinutesSinceMidnight(date: Date) -> Int? {
    let minuteOfDayComponents = truncateDateToMinuteOfDayComponents(date: date)
    let midnight = DateComponents(hour: 0, minute: 0)
    return calendar.dateComponents([.minute], from: midnight, to: minuteOfDayComponents).minute
}

/// Calculate the hour and minute from a date.
/// Determine whether that hour and minute fits within a range.
/// `True` means that this date fits inside the range the user had indicated
/// He would like to receive notifications.  
func date(_ date: Date, isContainedInMinuteOfDayRanges ranges: [ClosedRange<Int>]) -> Bool {
    guard let minutesSinceMidnight = calculateMinutesSinceMidnight(date: date) else { return false }

    var matchSuccess = false

    for range in ranges {
        if range.contains(minutesSinceMidnight) {
            matchSuccess = true
            break
        }
    }

    return matchSuccess
}

if let startMinute = calculateMinutesSinceMidnight(date: oneHourAgo),
    let endMinute = calculateMinutesSinceMidnight(date: oneHourFromNow) {
    print(date(now, isContainedInMinuteOfDayRanges: [startMinute ... endMinute]))
}

/// The start represents the beginning of an Integer based range.
/// The end represents the end of a range.
/// This struct exists because `ClosedRange` does not conform to `Codable`.
struct RangeBounds: Codable, Equatable {
    let start: Int
    let end: Int
}

struct PushNotificationState: Codable, Equatable {
    /// An array of `RangeBounds` structs.
    /// For example:  [[start: 360, end: 720], [start: 900, end: 960]] means
    /// that the user wants to receive notifications between 6 AM and 12 PM.
    /// and from 5 - 6 PM.
    var ranges: [RangeBounds] = [RangeBounds]()

    /// An OptionSet that allows users to the days of the week on which they wish to receive notifications.
    var daysOfWeek: DaysOfWeek = DaysOfWeek.unknown

    /// The routes for which the user has subscribed to notifications
    var routeIds: [String] = [String]()
}
