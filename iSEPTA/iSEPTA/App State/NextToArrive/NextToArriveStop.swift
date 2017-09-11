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
    let tripId: Int?

    let arrivalTime: Date
    let departureTime: Date
    let lastStopId: Int?
    let lastStopName: String?
    let delayMinutes: Int?
    let direction: RouteDirectionCode?

    init(routeId: String, routeName: String, tripId: Int?, arrivalTime: Date, departureTime: Date, lastStopId: Int?, lastStopName: String?, delayMinutes: Int?, direction: RouteDirectionCode?) {
        self.routeId = routeId
        self.routeName = routeName
        self.tripId = tripId

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

    areEqual = lhs.arrivalTime == rhs.arrivalTime
    guard areEqual else { return false }

    areEqual = lhs.departureTime == rhs.departureTime
    guard areEqual else { return false }

    return areEqual
}
