//
//  TripScheduleCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class TripScheduleCommand: BaseCommand {
    public typealias TripScheduleCommandCompletion = ([Trip]?, Error?) -> Void
    public static let sharedInstance = TripScheduleCommand()

    public func tripSchedules(forTransitMode transitMode: TransitMode, route: Route, selectedStart: Stop, selectedEnd: Stop, scheduleType: ScheduleType, completion: @escaping TripScheduleCommandCompletion) {
        let sqlQuery = TripScheduleSQLQuery(forTransitMode: transitMode, route: route, selectedStart: selectedStart, selectedEnd: selectedEnd, scheduleType: scheduleType)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Trip] in
            var trips = [Trip]()
            for row in statement {
                if
                    let col0 = row[0], let departureInt = col0 as? Int64,
                    let col1 = row[1], let arrivalInt = col1 as? Int64 {

                    let trip = Trip(departureInt: Int(departureInt), arrivalInt: Int(arrivalInt))
                    trips.append(trip)
                }
            }
            return trips
        }
    }
}
