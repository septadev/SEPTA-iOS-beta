//
//  RailRouteFromStopsSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

class RailRoutesFromStopsSQLQuery: SQLQueryProtocol {
    let routeId: String
    let startStopId: String
    let endStopId: String

    public var sqlBindings: [[String]] {
        return [[":route_id", routeId], [":startStopId", startStopId], [":endStopId", endStopId]]
    }

    public var fileName: String {
        return "railRoutesFromStops"
    }

    init(routeId: String, startStopId: Int, endStopId: Int) {
        self.routeId = String(routeId)
        self.startStopId = String(startStopId)
        self.endStopId = String(endStopId)
    }
}
