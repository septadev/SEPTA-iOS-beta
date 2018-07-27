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

    func dateFitsInRange(date: Date) -> Bool? {
        let range = startMinute.minutes ... endMinute.minutes
        guard let minutesSinceMidnight = MinutesSinceMidnight(date: date) else { return nil }
        return range.contains(minutesSinceMidnight.minutes)
    }
}
