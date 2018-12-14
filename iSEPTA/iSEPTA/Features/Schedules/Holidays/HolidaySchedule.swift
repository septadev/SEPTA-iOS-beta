//
//  HolidaySchedule.swift
//  HolidaySchedule
//
//  Created by Mark Broski on 12/14/17.
//  Copyright © 2017 Cap Tech. All rights reserved.
//

import Foundation

struct OnlineHolidaySchedule {
    let label: String
    let url: URL
}

struct HolidaySchedule: Decodable {
    enum SeptaHolidayDecodingError: Error {
        case badUrl
    }

    private enum HolidayMode {
        case invalidDate
        case noHoliday
        case railHoliday
        case otherHoliday
    }

    private let railOnlineSchedule: OnlineHolidaySchedule
    private let otherOnlineSchedule: OnlineHolidaySchedule
    private let septaOnlineSchedule: OnlineHolidaySchedule

    private let railHolidayMessage: String
    private let otherHolidayMessage: String
    private let otherHolidays: [Date]
    private let railHolidays: [Date]

    private var referenceDate: Date?
    private var holidayMode: HolidayMode?

    func onlineHolidaySchedules() -> [OnlineHolidaySchedule]? {
        guard let holidayMode = holidayMode else { return nil }
        switch holidayMode {
        case .railHoliday:
            return [septaOnlineSchedule, railOnlineSchedule, otherOnlineSchedule]

        case .otherHoliday:
            return [septaOnlineSchedule, otherOnlineSchedule]

        default:
            return nil
        }
    }

    mutating func setReferenceDate(_ date: Date) {
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        referenceDate = Calendar.current.date(from: todayComponents)

        holidayMode = determineHolidayMode()
    }

    private func determineHolidayMode() -> HolidayMode {
        guard let referenceDate = referenceDate else { return .invalidDate }
        if otherHolidays.contains(referenceDate) {
            return .otherHoliday
        } else if railHolidays.contains(referenceDate) {
            return .railHoliday
        } else {
            return .noHoliday
        }
    }

    func holidayMessage() -> String? {
        guard let holidayMode = holidayMode else { return nil }
        switch holidayMode {
        case .railHoliday:
            return railHolidayMessage
        case .otherHoliday:
            return otherHolidayMessage
        default:
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case railHolidayMessage
        case otherHolidayMessage
        case otherHolidays
        case railHolidays
        case otherHolidayUrl
        case otherHolidayUrlLabel
        case railHolidayUrl
        case railHolidayUrlLabel
        case SEPTAUrl
        case SEPTAUrlLabel
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
        railHolidayMessage = try container.decode(String.self, forKey: .railHolidayMessage) // extracting the data
        otherHolidayMessage = try container.decode(String.self, forKey: .otherHolidayMessage) // extracting the data
        let formatter = DateFormatters.ymdFormatter

        let otherHolidayStrings = try container.decode([String].self, forKey: .otherHolidays)
        otherHolidays = otherHolidayStrings.mapValidDates(formatter: formatter)

        let railHolidaysStrings = try container.decode([String].self, forKey: .railHolidays)
        railHolidays = railHolidaysStrings.mapValidDates(formatter: formatter)

        let otherHolidayUrlString = try container.decode(String.self, forKey: .otherHolidayUrl)
        let railHolidayUrlString = try container.decode(String.self, forKey: .railHolidayUrl)
        let SEPTAUrlString = try container.decode(String.self, forKey: .SEPTAUrl)
        let otherHolidayUrlLabel = try container.decode(String.self, forKey: .otherHolidayUrlLabel)
        let railHolidayUrlLabel = try container.decode(String.self, forKey: .railHolidayUrlLabel)
        let SEPTAUrlLabel = try container.decode(String.self, forKey: .SEPTAUrlLabel)

        if
            let otherHolidayUrl = URL(string: otherHolidayUrlString),
            let railHolidayUrl = URL(string: railHolidayUrlString),
            let septaUrl = URL(string: SEPTAUrlString) {
            septaOnlineSchedule = OnlineHolidaySchedule(label: SEPTAUrlLabel, url: septaUrl)
            railOnlineSchedule = OnlineHolidaySchedule(label: railHolidayUrlLabel, url: railHolidayUrl)
            otherOnlineSchedule = OnlineHolidaySchedule(label: otherHolidayUrlLabel, url: otherHolidayUrl)
        } else {
            throw SeptaHolidayDecodingError.badUrl
        }

        setReferenceDate(Date())
    }

    static func buildHolidaySchedule() -> HolidaySchedule? {
        guard let targetURL = Bundle.main.url(forResource: "holidaySchedule", withExtension: "json") else { return nil }
        do {
            let jsonData = try Data(contentsOf: targetURL)
            let decoder = JSONDecoder()
            let holidaySchedule = try decoder.decode(HolidaySchedule.self, from: jsonData)
            return holidaySchedule
        } catch {
            return nil
        }
    }
}

extension Sequence where Iterator.Element == String {
    func mapValidDates(formatter: DateFormatter) -> [Date] {
        return map({
            formatter.date(from: $0)
        }).compactMap { $0 }
    }
}
