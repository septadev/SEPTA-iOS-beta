// Septa. 2017

import Foundation

public class NumberFormatters {

    static var logNumberFormatter: NumberFormatter = {

        let formatter = NumberFormatter()
        formatter.positiveFormat = "000"
        return formatter
    }()
}
