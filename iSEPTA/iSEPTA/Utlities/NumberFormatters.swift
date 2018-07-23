// Septa. 2017

import Foundation

public class NumberFormatters {
    static var logNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "000"
        return formatter
    }()

    static var metersToMilesFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.positiveFormat = "0.00 mi"
        formatter.multiplier = 0.000621371
        return formatter
    }()
}
