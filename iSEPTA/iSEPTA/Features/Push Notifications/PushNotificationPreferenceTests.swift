//
//  PushNotificationPreferenceTests.swift
//  iSEPTATests
//
//  Created by Mark Broski on 7/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

@testable import Septa
import XCTest

class PushNotificationPreferenceTests: XCTestCase {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    let calendar = Calendar.current

    func testDayOfWeek() {
        let dateString = "2018-07-23" // a Monday
        let date = dateFormatter.date(from: dateString)!
        XCTAssertEqual(DaysOfWeekOptionSet.monday.matchesDate(date), true)
        XCTAssertEqual(DaysOfWeekOptionSet.tuesday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.wednesday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.thursday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.friday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.saturday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.sunday.matchesDate(date), false)
    }

    func testDayOfWeek2() {
        let dateString = "2018-07-25" // A Wednesday
        let date = dateFormatter.date(from: dateString)!
        XCTAssertEqual(DaysOfWeekOptionSet.monday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.tuesday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.wednesday.matchesDate(date), true)
        XCTAssertEqual(DaysOfWeekOptionSet.thursday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.friday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.saturday.matchesDate(date), false)
        XCTAssertEqual(DaysOfWeekOptionSet.sunday.matchesDate(date), false)
    }

    func testDayOfWeek3() {
        let dateString = "2018-07-25" // a Wednesday
        let date = dateFormatter.date(from: dateString)!
        let daysOfWeek: DaysOfWeekOptionSet = [.monday, .wednesday]
        XCTAssertEqual(daysOfWeek.matchesDate(date), true)
    }

    func testDayOfWeek4() {
        let dateString = "2018-07-24" // a Tuesday
        let date = dateFormatter.date(from: dateString)!
        let daysOfWeek: DaysOfWeekOptionSet = [.monday, .wednesday]
        XCTAssertEqual(daysOfWeek.matchesDate(date), false)
    }

    func testPushNotificationPreferenceState() {
        let testDateComponents = DateComponents(hour: 1, minute: 30)
        let testDate = calendar.date(from: testDateComponents)!
        let minutesSinceMidnight = MinutesSinceMidnight(date: testDate)!
        XCTAssertEqual(90, minutesSinceMidnight.minutes)
        let timeOnlyDateString = DateFormatters.networkFormatter.string(from: minutesSinceMidnight.timeOnlyDate!)
        XCTAssertTrue(timeOnlyDateString.contains("0001-01-01T01:30:00.000"))
    }

    func testPushNotificationPreferenceState2() {
        let testDateComponents = DateComponents(year: 2018, month: 7, day: 12, hour: 15, minute: 45)
        let testDate = calendar.date(from: testDateComponents)!
        let minutesSinceMidnight = MinutesSinceMidnight(date: testDate)!
        XCTAssertEqual(15 * 60 + 45, minutesSinceMidnight.minutes)
        let timeOnlyDateString = DateFormatters.networkFormatter.string(from: minutesSinceMidnight.timeOnlyDate!)
        XCTAssertTrue(timeOnlyDateString.contains("0001-01-01T15:45:00.000"))
    }

    func testNotificationTimeWindow() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)
        let testTime = dateFromHourMinute(hour: 8, minute: 15)
        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!
        let actualResult = timeWindow.dateFitsInRange(date: testTime)!
        let expectedResult = true
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testNotificationTimeWindow2() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)
        let testTime = dateFromHourMinute(hour: 9, minute: 30)
        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!
        let actualResult = timeWindow.dateFitsInRange(date: testTime)!
        let expectedResult = true
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testNotificationTimeWindow3() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)
        let testTime = dateFromHourMinute(hour: 10, minute: 30)
        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!
        let actualResult = timeWindow.dateFitsInRange(date: testTime)!
        let expectedResult = false
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testPushNotificationState1() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)

        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!

        let daysOfWeek: DaysOfWeekOptionSet = [.wednesday, .friday]

        let routeIds = ["44", "37"]

        var preferenceState = PushNotificationPreferenceState()
        preferenceState.notificationTimeWindows = [timeWindow]
        preferenceState.daysOfWeek = daysOfWeek
        preferenceState.routeIds = routeIds

        let testDate = dateFromComponents(year: 2018, month: 7, day: 27, hour: 9, minute: 29) // Friday
        let testRoute = "37"
        let expectedResult = true
        let actualResult = preferenceState.userShouldReceiveNotification(atDate: testDate, forRouteId: testRoute)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPushNotificationState2() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)

        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!

        let daysOfWeek: DaysOfWeekOptionSet = [.wednesday, .friday]

        let routeIds = ["44", "37"]

        var preferenceState = PushNotificationPreferenceState()
        preferenceState.notificationTimeWindows = [timeWindow]
        preferenceState.daysOfWeek = daysOfWeek
        preferenceState.routeIds = routeIds

        let testDate = dateFromComponents(year: 2018, month: 7, day: 27, hour: 9, minute: 29) // Friday
        let testRoute = "442" /// Adding in a non matching route
        let expectedResult = false
        let actualResult = preferenceState.userShouldReceiveNotification(atDate: testDate, forRouteId: testRoute)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPushNotificationState3() {
        let startTime1 = dateFromHourMinute(hour: 7, minute: 30)
        let endTime1 = dateFromHourMinute(hour: 9, minute: 30)
        let timeWindow1 = NotificationTimeWindow(startTime: startTime1, endTime: endTime1)!

        let startTime2 = dateFromHourMinute(hour: 17, minute: 30)
        let endTime2 = dateFromHourMinute(hour: 18, minute: 30)
        let timeWindow2 = NotificationTimeWindow(startTime: startTime2, endTime: endTime2)!

        let daysOfWeek: DaysOfWeekOptionSet = [.wednesday, .friday]

        let routeIds = ["44", "37"]

        var preferenceState = PushNotificationPreferenceState()
        preferenceState.notificationTimeWindows = [timeWindow1, timeWindow2] /// Adding multiple Time Windows
        preferenceState.daysOfWeek = daysOfWeek
        preferenceState.routeIds = routeIds

        let testDate = dateFromComponents(year: 2018, month: 7, day: 27, hour: 17, minute: 55) // Friday
        let testRoute = "44" /// Adding in a non matching route
        let expectedResult = true
        let actualResult = preferenceState.userShouldReceiveNotification(atDate: testDate, forRouteId: testRoute)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPushNotificationState4() {
        let startTime = dateFromHourMinute(hour: 7, minute: 30)
        let endTime = dateFromHourMinute(hour: 9, minute: 30)

        let timeWindow = NotificationTimeWindow(startTime: startTime, endTime: endTime)!

        let daysOfWeek: DaysOfWeekOptionSet = [.wednesday] // will no longer match fridays

        let routeIds = ["44", "37"]

        var preferenceState = PushNotificationPreferenceState()
        preferenceState.notificationTimeWindows = [timeWindow]
        preferenceState.daysOfWeek = daysOfWeek
        preferenceState.routeIds = routeIds

        let testDate = dateFromComponents(year: 2018, month: 7, day: 27, hour: 9, minute: 29) // Friday
        let testRoute = "37"
        let expectedResult = false
        let actualResult = preferenceState.userShouldReceiveNotification(atDate: testDate, forRouteId: testRoute)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func dateFromHourMinute(hour: Int, minute: Int) -> Date {
        let testDateComponents = DateComponents(hour: hour, minute: minute)
        return calendar.date(from: testDateComponents)!
    }

    func dateFromComponents(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        let testDateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: testDateComponents)!
    }
}
