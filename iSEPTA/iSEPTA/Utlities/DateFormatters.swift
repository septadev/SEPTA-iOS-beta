// Septa. 2017

import Foundation

public class DateFormatters {

    static var durationFormatter: DateComponentsFormatter = {

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        // formatter.includesApproximationPhrase = false
        // formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    static var fileFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ss-hh-mm"
        return formatter
    }()

    static var timeFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static var networkFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static var hourMinuteFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static func formatDurationString(startDate: Date, endDate: Date) -> String? {
        let startString = DateFormatters.hourMinuteFormatter.string(from: startDate)
        let endString = DateFormatters.hourMinuteFormatter.string(from: endDate)

        return "\(startString) - \(endString)"
    }

    static func formatTimeFromNow(date comparisonDate: Date) -> String? {
        let calendar = Calendar.current
        let nonSeconds: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let rightNowComponents = calendar.dateComponents(nonSeconds, from: Date())
        let comparisonDateComponents = calendar.dateComponents(nonSeconds, from: comparisonDate)
        let diffComponents = calendar.dateComponents(nonSeconds, from: rightNowComponents, to: comparisonDateComponents)

        if let hour = diffComponents.hour, let minute = diffComponents.minute, hour == 0, minute <= 0 {
            return "now"
        } else {
            return durationFormatter.string(from: diffComponents)
        }
    }
}
