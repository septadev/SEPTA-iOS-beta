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
    let routeDirecctionCodeString: String

    var sqlBindings: [[String]] {

        return [[":start_stop_id", startId], [":end_stop_id", stopId], [":service_id", serviceId], [":direction_id", routeDirecctionCodeString]]
    }

    var fileName: String {
        switch transitMode {
        case .rail:
            return "railTripSchedule"
        default:
            return "busTripSchedule"
        }
    }

    init(forTransitMode transitMode: TransitMode, route: Route, selectedStart start: Stop,
         selectedEnd stop: Stop, scheduleType: ScheduleType) {
        if transitMode == .rail {
            switch scheduleType {
            case .weekday:
                serviceId = "8"
            case .saturday:
                serviceId = "1"
            case .sunday:
                serviceId = "64"
            case .friday:
                serviceId = "2"
            case .mondayThroughThursday:
                serviceId = "32"
            }
        } else {
            switch scheduleType {
            case .saturday:
                serviceId = "1"
            case .sunday:
                serviceId = "64"
            default:
                serviceId = "8"
            }
        }

        self.transitMode = transitMode

        startId = String(start.stopId)
        stopId = String(stop.stopId)

        routeDirecctionCodeString = String(route.routeDirectionCode.rawValue)
    }
}
