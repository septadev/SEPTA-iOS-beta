//
//  TripScheduleCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation


class TripScheduleCommand: BaseCommand {
    public typealias TripEndCommandCompletion = ([Trip]?, Error?) -> Void
    static let sharedInstance = TripScheduleCommand()
    private override init{}


public func stops(forTransitMode transitMode: TransitMode, forRoute route: Route, tripStart: Stop, completion: @escaping TripEndCommandCompletion) {
        let sqlQuery = TripEndSQLQuery(transitMode: transitMode, route: route, tripStart: tripStart)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
            var stops = [Stop]()
            for row in statement {
                if
                    let col0 = row[0], let stopIdInt = col0 as? Int64,
                    let col1 = row[1], let stopName = col1 as? String,
                    let col2 = row[2], let stopLatitude = col2 as? Double,
                    let col3 = row[3], let stopLongitude = col3 as? Double,
                    let col4 = row[4], let wheelchairBoardingInt = col4 as? Int64,
                    let col5 = row[5], let weekdayServiceInt = col5 as? Int64,
                    let col6 = row[6], let saturdayServiceInt = col6 as? Int64,
                    let col7 = row[7], let sundayServiceInt = col7 as? Int64 {
                    let stopId = Int(stopIdInt)
                    let wheelchairBoarding = wheelchairBoardingInt == 1
                    let weekdayService = weekdayServiceInt == 1
                    let saturdayService = saturdayServiceInt == 1
                    let sundayService = sundayServiceInt == 1
                    let stop = Stop(stopId: stopId, stopName: stopName, stopLatitude: stopLatitude, stopLongitude: stopLongitude, wheelchairBoarding: wheelchairBoarding, weekdayService: weekdayService, saturdayService: saturdayService, sundayService: sundayService)
                    stops.append(stop)
                }
            }
            return stops
        }
    }
}
