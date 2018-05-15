//
//  TripReverseCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class StopReverseCommand: BaseCommand {
    public typealias StopReverseCommandCompletion = ([TripStopId]?, Error?) -> Void
    public static let sharedInstance = StopReverseCommand()

    public func reverseStops(forTransitMode transitMode: TransitMode, tripStopId: TripStopId, completion: @escaping StopReverseCommandCompletion) {
        let sqlQuery = StopReverseSQLQuery(forTransitMode: transitMode, tripStopId: tripStopId)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [TripStopId] in
            var tripStopIdArray = [TripStopId]()
            for row in statement {
                if
                    let col0 = row[0], let startIdInt = col0 as? Int64,
                    let col1 = row[1], let stopIdInt = col1 as? Int64 {
                    let tripStopId = TripStopId(start: Int(startIdInt), end: Int(stopIdInt))
                    tripStopIdArray.append(tripStopId)
                }
            }
            return tripStopIdArray
        }
    }
}
