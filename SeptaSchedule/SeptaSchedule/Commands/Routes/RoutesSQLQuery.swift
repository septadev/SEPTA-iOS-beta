//
//  RoutesSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class RoutesSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode

    public var sqlBindings: [[String]] {

        switch transitMode {
        case .bus:
            return [[":route_id", " R.route_id not in ( 'BSO', 'BSL', 'MFL' ) "], [":route_type", " R.route_type = 3"]]
        case .nhsl:
            return [[":route_id", "  R.route_id = 'NHSL'"], [":route_type", " 1 = 1 "]]
        case .trolley:
            return [[":route_id", " R.route_id != 'NHSL' "], [":route_type", "  R.route_type = 0 "]]
        case .subway:
            return [[":route_id", " R.route_id in ( 'BSO', 'BSL', 'MFL' , 'MFO' ) "], [":route_type", "1 = 1 "]]
        case .rail:
            return [[String]]()
        }
    }

    public var fileName: String {
        switch transitMode {
        case .bus: return "busRoute"
        case .rail: return "railRoute"
        case .subway: return "busRoute"
        case .trolley: return "busRoute"
        case .nhsl: return "busRoute"
        }
    }

    init(transitMode: TransitMode) {
        self.transitMode = transitMode
    }
}
