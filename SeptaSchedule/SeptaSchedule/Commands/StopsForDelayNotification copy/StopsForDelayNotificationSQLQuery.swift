//
//  RailRouteFromStopsSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

class StopsForDelayNotificationSQLQuery: SQLQueryProtocol {
    let routeId: String
    let tripId: String
    let days: String
    let endStopId: String

    public var sqlBindings: [[String]] {
        return [[":route_id", routeId], [":trip_id", tripId], [":days", days], [":end_stop_id", endStopId]]
    }

    public var fileName: String {
        return "stopsForDelayNotification"
    }

    init(routeId: String, tripId: String, date: Date, endStopId: String) {
        self.routeId = String(routeId)
        self.tripId = tripId
        if let days = RailCalendar.convertDayOfWeekToRailCalendarBitMaskForDate(date) {
            self.days = String(days)
        } else {
            days = String(0)
        }
        self.endStopId = endStopId
    }
}
