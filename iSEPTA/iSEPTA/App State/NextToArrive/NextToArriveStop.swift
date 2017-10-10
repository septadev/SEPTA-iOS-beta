//
//  NextToArriveStop.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import CoreLocation

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
    let vehicleLocationCoordinate: CLLocationCoordinate2D?
    let vehicleIds: [String]?

    init(routeId: String, routeName: String, tripId: Int?, arrivalTime: Date, departureTime: Date, lastStopId: Int?, lastStopName: String?, delayMinutes: Int?, direction: RouteDirectionCode?, vehicleLocationCoordinate: CLLocationCoordinate2D?, vehicleIds: [String]?) {
        self.routeId = routeId
        self.routeName = routeName
        self.tripId = tripId

        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
        self.lastStopId = lastStopId
        self.lastStopName = lastStopName
        self.delayMinutes = delayMinutes
        self.direction = direction
        self.vehicleLocationCoordinate = vehicleLocationCoordinate
        self.vehicleIds = vehicleIds
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
