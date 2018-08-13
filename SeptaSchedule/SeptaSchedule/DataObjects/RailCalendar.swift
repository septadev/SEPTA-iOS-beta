//
//  RailCalendar.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

class RailCalendar {
    /// To get rail trips that are happening only on particular day of the week.
    static func convertDayOfWeekToRailCalendarBitMaskForDate(_ date: Date) -> Int? {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        switch weekday {
        case 1: return 64 // Sunday
        case 2 ... 5: return 32 // Monday through Thursday
        case 6: return 2 // Friday
        case 7: return 1 // Saturday
        default: return nil
        }
    }
}
