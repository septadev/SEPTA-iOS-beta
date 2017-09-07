//
//  NextToArriveStop.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct NextToArriveStop {

    let routeId: String
    let routeName: String
    let tripId: Int
    let lineName: String
    let arrivalTime: Date
    let departureTime: Date
    let lastStopId: Int
    let lastStopName: String
    let delayMinutes: Int
    let direction: RouteDirectionCode

    init(routeId: String, routeName: String, tripId: Int, lineName: String = "", arrivalTime: Date, departureTime: Date, lastStopId: Int, lastStopName: String, delayMinutes: Int = 0, direction: RouteDirectionCode) {
        self.routeId = routeId
        self.routeName = routeName
        self.tripId = tripId
        self.lineName = lineName
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
        self.lastStopId = lastStopId
        self.lastStopName = lastStopName
        self.delayMinutes = delayMinutes
        self.direction = direction
    }
}

extension NextToArriveStop: Equatable {}
func ==(lhs: NextToArriveStop, rhs: NextToArriveStop) -> Bool {
    var areEqual = true

    areEqual = lhs.routeId == rhs.routeId
    guard areEqual else { return false }

    areEqual = lhs.routeName == rhs.routeName
    guard areEqual else { return false }

    areEqual = lhs.tripId == rhs.tripId
    guard areEqual else { return false }

    areEqual = lhs.lineName == rhs.lineName
    guard areEqual else { return false }

    areEqual = lhs.arrivalTime == rhs.arrivalTime
    guard areEqual else { return false }

    areEqual = lhs.departureTime == rhs.departureTime
    guard areEqual else { return false }

    areEqual = lhs.lastStopId == rhs.lastStopId
    guard areEqual else { return false }

    areEqual = lhs.lastStopName == rhs.lastStopName
    guard areEqual else { return false }

    areEqual = lhs.delayMinutes == rhs.delayMinutes
    guard areEqual else { return false }

    return areEqual
}
