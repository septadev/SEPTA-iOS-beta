//
//  TripEndSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class TripEndSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let routeId: String
    let routeDirecctionCodeString: String
    let stopId: String

    var sqlBindings: [[String]] {
        return [[":route_id", routeId], [":direction_id", routeDirecctionCodeString], [":stop_id", stopId]]
    }

    var fileName: String {
        if routeId == Route.allRailRoutesRouteId() {
            return "allRailEnds"
        }
        switch transitMode {
        case .rail:
            return "railTripEnd"
        default:
            return "busTripEnd"
        }
    }

    init(transitMode: TransitMode, route: Route, tripStart: Stop) {
        self.transitMode = transitMode
        routeId = route.routeId
        routeDirecctionCodeString = String(route.routeDirectionCode.rawValue)
        stopId = String(tripStart.stopId)
    }
}
