//
//  TripScheduleSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class TripScheduleSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode
    let serviceId: String
    let startId: String
    let stopId: String

    var sqlBindings: [[String]] {
        //        return [[":route_id", routeId], [":direction_id", routeDirecctionCodeString], [":stop_id", stopId]]
        return [[String]]()
    }

    var fileName: String {
        //        switch transitMode {
        //        case .rail:
        //            return "railTripEnd"
        //        default:
        //            return "busTripEnd"
        //        }
        return "busTripEnd"
    }

    init(forTransitMode transitMode: TransitMode, selectedStart start: Stop, selectedEnd stop: Stop, scheduleType: ScheduleType) {
        self.transitMode = transitMode
        serviceId = String(scheduleType.rawValue)
        startId = String(start.stopId)
        stopId = String(stop.stopId)
    }
}
