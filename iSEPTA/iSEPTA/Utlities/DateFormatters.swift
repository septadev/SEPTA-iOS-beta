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
}
