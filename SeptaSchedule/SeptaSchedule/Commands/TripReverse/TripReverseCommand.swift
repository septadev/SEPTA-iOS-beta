//
//  RouteReverseCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class TripReverseCommand: BaseCommand {

    public static let sharedInstance = TripReverseCommand()

    public func reverseTrip(forTransitMode transitMode: TransitMode, tripStopId: TripStopId, scheduleType: ScheduleType, completion: @escaping TripScheduleCommandCompletion) {
        let sqlQuery = TripReverseSQLQuery(forTransitMode: transitMode, tripStopId: tripStopId, scheduleType: scheduleType)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Trip] in
            var trips = [Trip]()
            for row in statement {
                if
                    let col0 = row[0], let departureInt = col0 as? Int64,
                    let col1 = row[1], let arrivalInt = col1 as? Int64,
                    let col2 = row[2], let blockId = col2 as? String,
                    let col3 = row[3], let tripId = col3 as? String {

                    let trip = Trip(tripId: tripId, departureInt: Int(departureInt), arrivalInt: Int(arrivalInt), blockId: blockId)
                    trips.append(trip)
                }
            }
            return trips
        }
    }
}
