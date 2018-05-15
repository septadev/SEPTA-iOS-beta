//
//  ReverseRouteSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
class ReverseRouteSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let direction_id: String
    let routeId: String

    var sqlBindings: [[String]] {

        return [[":route_id", routeId], [":direction_id", direction_id]]
    }

    var fileName: String {
        switch transitMode {
        case .rail:
            return "railReverseRoute"
        default:
            return "busReverseRoute"
        }
    }

    init(forTransitMode transitMode: TransitMode, routeId: String, routeDirectionCode: RouteDirectionCode) {
        self.transitMode = transitMode
        direction_id = String(routeDirectionCode.rawValue)
        self.routeId = routeId
    }
}
