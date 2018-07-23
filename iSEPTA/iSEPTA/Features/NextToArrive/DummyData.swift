//
//  DummyData.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension Route {
    static func dummyRoute(routeId: String) -> Route {
        return Route(routeId: routeId, routeShortName: "", routeLongName: "", routeDirectionCode: .inbound)
    }
}

extension Stop {
    static func dummyStop(stopId: Int) -> Stop {
        return Stop(stopId: stopId, sequence: 1, stopName: "", stopLatitude: 0, stopLongitude: 0, wheelchairBoarding: false, weekdayService: false, saturdayService: false, sundayService: false)
    }
}

extension ScheduleRequest {
    static func dummyRequest(transitMode: TransitMode, routeId: String, startId: Int, stopId: Int) -> ScheduleRequest {
        return ScheduleRequest(transitMode: transitMode,
                               selectedRoute: Route.dummyRoute(routeId: routeId),
                               selectedStart: Stop.dummyStop(stopId: startId),
                               selectedEnd: Stop.dummyStop(stopId: stopId),
                               scheduleType: .weekday, reverseStops: false)
    }
}
