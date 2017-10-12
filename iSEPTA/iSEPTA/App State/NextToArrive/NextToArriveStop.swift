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
import SeptaRest

struct NextToArriveStop {
    let updatedTime = Date()
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
    var nextToArriveDetail: RealTimeArrivalDetail?
    let hasRealTimeData: Bool
    var service: String?

    init(routeId: String, routeName: String, tripId: Int?, arrivalTime: Date, departureTime: Date, lastStopId: Int?, lastStopName: String?, delayMinutes: Int?, direction: RouteDirectionCode?, vehicleLocationCoordinate: CLLocationCoordinate2D?, vehicleIds: [String]?, hasRealTimeData: Bool?, service: String?) {
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
        if let hasRealTimeData = hasRealTimeData {
            self.hasRealTimeData = hasRealTimeData
        } else {
            self.hasRealTimeData = false
        }
        self.service = service
    }
}

extension NextToArriveStop: Equatable {}
func ==(lhs: NextToArriveStop, rhs: NextToArriveStop) -> Bool {
    return lhs.updatedTime != rhs.updatedTime
}
