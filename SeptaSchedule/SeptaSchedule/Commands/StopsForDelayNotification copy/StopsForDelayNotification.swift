//
//  RailRoutFromStopsCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//
import Foundation

public class StopsForDelayNotification: BaseCommand {
    public typealias StopsForDelayNotificationCompletion = ([Stop]?, Error?) -> Void
    public static let sharedInstance = StopsForDelayNotification()

    public override init() {}

    public func stops(routeId: String, tripId: String, date: Date, endStopId: String, completion: @escaping StopsForDelayNotificationCompletion) {
        let sqlQuery = StopsForDelayNotificationSQLQuery(routeId: routeId, tripId: tripId, date: date, endStopId: endStopId)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
            var stops = [Stop]()
            for row in statement {
                if
                    let col0 = row[0], let stopIdInt = col0 as? Int64,
                    let col1 = row[1], let stopName = col1 as? String,
                    let col2 = row[2], let stopLatitude = col2 as? Double,
                    let col3 = row[3], let stopLongitude = col3 as? Double {
                    let stopId = Int(stopIdInt)
                    let wheelchairBoarding = true
                    let weekdayService = true
                    let saturdayService = true
                    let sundayService = true
                    let stop = Stop(stopId: stopId, sequence: 1, stopName: stopName, stopLatitude: stopLatitude, stopLongitude: stopLongitude, wheelchairBoarding: wheelchairBoarding, weekdayService: weekdayService, saturdayService: saturdayService, sundayService: sundayService)
                    stops.append(stop)
                }
            }
            return stops
        }
    }
}
