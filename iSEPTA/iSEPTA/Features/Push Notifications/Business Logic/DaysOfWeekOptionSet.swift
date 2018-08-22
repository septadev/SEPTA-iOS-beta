//
//  DaysOfWeekOptionSet.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct DaysOfWeekOptionSet: OptionSet, Codable, Equatable {
    let rawValue: Int
    static let unknown = DaysOfWeekOptionSet(rawValue: 0 << 0)
    static let monday = DaysOfWeekOptionSet(rawValue: 1 << 0)
    static let tuesday = DaysOfWeekOptionSet(rawValue: 1 << 1)
    static let wednesday = DaysOfWeekOptionSet(rawValue: 1 << 2)
    static let thursday = DaysOfWeekOptionSet(rawValue: 1 << 3)
    static let friday = DaysOfWeekOptionSet(rawValue: 1 << 4)
    static let saturday = DaysOfWeekOptionSet(rawValue: 1 << 5)
    static let sunday = DaysOfWeekOptionSet(rawValue: 1 << 6)

    func matchesDate(_ date: Date) -> Bool {
        let filteredComponents = Calendar.current.dateComponents([.weekday], from: date)
        guard let weekday = filteredComponents.weekday else { return false }
        let dayOfWeek = DaysOfWeekOptionSet.fromWeekdayComponent(weekday: weekday)
        return contains(dayOfWeek)
    }

    func selectedDays() -> [String] {
        var days: [String] = []

        if contains(.sunday) { days.append("1") }
        if contains(.monday) { days.append("2") }
        if contains(.tuesday) { days.append("3") }
        if contains(.wednesday) { days.append("4") }
        if contains(.thursday) { days.append("5") }
        if contains(.friday) { days.append("6") }
        if contains(.saturday) { days.append("7") }

        return days
    }

    private static func fromWeekdayComponent(weekday: Int) -> DaysOfWeekOptionSet {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .unknown
        }
    }

    static func mondayThroughFriday() -> DaysOfWeekOptionSet {
        return [.monday, .tuesday, .wednesday, .thursday, .friday]
    }
}
