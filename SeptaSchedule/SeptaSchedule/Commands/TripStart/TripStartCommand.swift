//
//  TripStartCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
/*
 SELECT
 S.stop_id stopId,
 S.stop_name stopName,
 cast (S.stop_lat as decimal) stopLatitude,
 cast (S.stop_lon as decimal) stopLongitude,
 case when S.wheelchair_boarding = '1' then 1 else 0  end wheelchairBoarding,
 MAX(CASE WHEN T.service_id = '1'
 THEN 1 else 0 END) weekdayService,
 MAX(CASE WHEN
 T.service_id = '2'
 THEN 1  else 0 END) saturdayService,
 MAX(CASE WHEN
 T.service_id = '3'
 THEN 1  else 0 END) AS sundayService
 FROM trips_bus T
 JOIN routes_bus R
 ON T.route_id = R.route_id
 JOIN stops_bus S
 ON R.route_id = T.route_id
 WHERE T.route_id = '44' AND direction_id = '1'
 GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;
 */

public class TripStartCommand: BaseCommand {
    public typealias TripStartCommandCompletion = ([Stop]?, Error?) -> Void
    public static let sharedInstance = TripStartCommand()

    private override init() {}

    public func stops(forTransitMode transitMode: TransitMode, forRoute route: Route, completion: @escaping TripStartCommandCompletion) {
        let sqlQuery = TripStartSQLQuery(transitMode: transitMode, route: route)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
            var stops = [Stop]()
            for row in statement {
                if
                    let col0 = row[0], let stopIdInt = col0 as? Int64,
                    let col1 = row[1], let sequence = col1 as? Int64,
                    let col2 = row[2], let stopName = col2 as? String,
                    let col3 = row[3], let stopLatitude = col3 as? Double,
                    let col4 = row[4], let stopLongitude = col4 as? Double,
                    let col5 = row[5], let wheelchairBoardingInt = col5 as? Int64,
                    let col6 = row[6], let weekdayServiceInt = col6 as? Int64,
                    let col7 = row[7], let saturdayServiceInt = col7 as? Int64,
                    let col8 = row[8], let sundayServiceInt = col8 as? Int64 {
                    let stopId = Int(stopIdInt)
                    let wheelchairBoarding = wheelchairBoardingInt == 1
                    let weekdayService = weekdayServiceInt == 1
                    let saturdayService = saturdayServiceInt == 1
                    let sundayService = sundayServiceInt == 1
                    let stop = Stop(stopId: stopId, sequence: Int(sequence), stopName: stopName, stopLatitude: stopLatitude, stopLongitude: stopLongitude, wheelchairBoarding: wheelchairBoarding, weekdayService: weekdayService, saturdayService: saturdayService, sundayService: sundayService)
                    stops.append(stop)
                }
            }
            return stops
        }
    }
}
