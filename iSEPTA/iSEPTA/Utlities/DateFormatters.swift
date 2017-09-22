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

    static func formatTimeFromNow(date: Date) -> String? {
        let rightNow = Date()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.hour, .minute], from: rightNow, to: date)
        if let hour = diff.hour, let minute = diff.minute, hour == 0, minute == 0 {
            return "now"
        } else if let hour = diff.hour, let minute = diff.minute, hour == 0, minute < 0 {
            var negativeComponents = DateComponents()
            negativeComponents.minute = -minute
            if let durationString = durationFormatter.string(from: negativeComponents) {
                return "\(durationString) ago"
            } else {
                return nil
            }
        } else {
            return durationFormatter.string(from: diff)
        }
    }
}
