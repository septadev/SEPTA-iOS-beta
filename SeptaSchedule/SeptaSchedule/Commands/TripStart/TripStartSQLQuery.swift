//
//  TripStartSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class TripStartSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let routeId: String
    let routeDirecctionCodeString: String

    var sqlBindings: [[String]] {
        switch transitMode {
        case .rail:
            return [[String]]()
        default:
            return [[":route_id", routeId], [":direction_id", routeDirecctionCodeString]]
        }
    }

    var fileName: String {
        switch transitMode {
        case .rail:
            return "railTripStart"
        default:
            return "busTripStart"
        }
    }

    init(transitMode: TransitMode, route: Route) {
        self.transitMode = transitMode
        routeId = route.routeId
        routeDirecctionCodeString = String(route.routeDirectionCode.rawValue)
    }
}
