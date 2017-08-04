// SEPTA.org, created on 8/2/17.

import Foundation

public class DateFormatters {

    static  var durationFormatter: DateComponentsFormatter = {

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        // formatter.includesApproximationPhrase = false
        // formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    static var timeFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
