//
//  File.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

/// The start represents the beginning of an Integer based range.
/// The end represents the end of a range.
/// This struct exists because `ClosedRange` does not conform to `Codable`.
struct NotificationTimeWindow: Codable, Equatable {
    let startMinute: MinutesSinceMidnight

    let endMinute: MinutesSinceMidnight

    init?(startTime: Date, endTime: Date) {
        guard let startMinute = MinutesSinceMidnight(date: startTime),
            let endMinute = MinutesSinceMidnight(date: endTime) else { return nil }
        self.startMinute = startMinute
        self.endMinute = endMinute
    }

    private init(startMinute: Int, endMinute: Int) {
        self.startMinute = MinutesSinceMidnight(startMinute)
        self.endMinute = MinutesSinceMidnight(endMinute)
    }

    func dateFitsInRange(date: Date) -> Bool? {
        let range = startMinute.minutes ... endMinute.minutes
        guard let minutesSinceMidnight = MinutesSinceMidnight(date: date) else { return nil }
        return range.contains(minutesSinceMidnight.minutes)
    }

    static func defaultValue() -> NotificationTimeWindow { // 442, 553
        return NotificationTimeWindow(startMinute: 7 * 60 + 12, endMinute: 9 * 60 + 13)
    }
}
