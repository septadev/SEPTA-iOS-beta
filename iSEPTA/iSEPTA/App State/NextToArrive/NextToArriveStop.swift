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
    let transitMode: TransitMode
    var updatedTime = Date()
    let routeId: String
    let routeName: String
    let tripId: Int?
    let arrivalTime: Date
    let departureTime: Date
    var lastStopId: Int?
    var lastStopName: String?
    var delayMinutes: Int?
    let direction: RouteDirectionCode?
    var vehicleLocationCoordinate: CLLocationCoordinate2D?
    var vehicleIds: [String]?
    private(set) var nextToArriveDetail: RealTimeArrivalDetail?
    let hasRealTimeData: Bool
    var service: String?

    init(transitMode: TransitMode, routeId: String, routeName: String, tripId: Int?, arrivalTime: Date, departureTime: Date, lastStopId: Int?, lastStopName: String?, delayMinutes: Int?, direction: RouteDirectionCode?, vehicleLocationCoordinate: CLLocationCoordinate2D?, vehicleIds: [String]?, hasRealTimeData: Bool?, service: String?) {
        self.transitMode = transitMode
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

    mutating func addRealTimeData(nextToArriveDetail: RealTimeArrivalDetail?) {
        self.nextToArriveDetail = nextToArriveDetail
        updatedTime = Date()
        guard let detail = nextToArriveDetail else { return }

        if let newLat = detail.latitude, let newLon = detail.longitude {
            vehicleLocationCoordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        }

        if let railDetails = nextToArriveDetail as? NextToArriveRailDetails {
            if let vehicleIds = railDetails.consist {
                self.vehicleIds = vehicleIds
            }
        }
    }
}

extension NextToArriveStop: Equatable {}
func ==(lhs: NextToArriveStop, rhs: NextToArriveStop) -> Bool {
    return lhs.updatedTime != rhs.updatedTime
}
