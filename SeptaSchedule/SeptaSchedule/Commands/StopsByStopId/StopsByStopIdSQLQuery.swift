//
//  StopsByStopIdSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
class StopsByStopIdSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let start_stop_id: String
    let end_stop_id: String

    var sqlBindings: [[String]] {
        return [[":start_stop_id", start_stop_id], [":end_stop_id", end_stop_id]]
    }

    var fileName: String {
        switch transitMode {
        case .rail:
            return "railStopsByStopId"
        default:
            return "busStopsByStopId"
        }
    }

    init(forTransitMode transitMode: TransitMode, tripStopId: TripStopId) {
        self.transitMode = transitMode
        start_stop_id = String(tripStopId.start)
        end_stop_id = String(tripStopId.end)
    }
}
