//
//  MinutesSinceMidnight.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

/// given a date, stores the minutes of that date since midignt
struct MinutesSinceMidnight: Codable, Equatable {
    /// The number of minutes since midnight
    let minutes: Int

    /// The number of minutes since midnight expressed as a date.
    /// Year, month, day, seconds information is stripped away from this date.
    var timeOnlyDate: Date? {
        let components = DateComponents(minute: minutes)
        return Calendar.current.date(from: components)
    }

    init?(date: Date) {
        let components = MinutesSinceMidnight.minutesSinceMidnightComponents(date: date)
        guard let minutes = components.minute else { return nil }
        self.minutes = minutes
    }

    init(_ minutes: Int) {
        self.minutes = minutes
    }

    private static func minutesSinceMidnightComponents(date: Date) -> DateComponents {
        let calendar = Calendar.current
        let minuteOfDayComponents = calendar.dateComponents([.hour, .minute], from: date)
        let midnight = DateComponents(hour: 0, minute: 0)
        return calendar.dateComponents([.minute], from: midnight, to: minuteOfDayComponents)
    }
}
