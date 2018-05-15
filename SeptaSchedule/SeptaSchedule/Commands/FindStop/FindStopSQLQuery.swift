//
//  RailStopSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class FindStopSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let stopId: String

    var sqlBindings: [[String]] {
        switch transitMode {
        case .rail:
            return [[":table_name", "stops_rail"], [":stop_id", stopId]]
        default:
            return [[":table_name", "stops_bus"], [":stop_id", stopId]]
        }
    }

    var fileName: String {
        return "findStop"
    }

    init(transitMode: TransitMode, stopId: Int) {
        self.transitMode = transitMode
        self.stopId = String(stopId)
    }
}
