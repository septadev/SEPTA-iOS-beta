// Septa. 2017

import Foundation

public class TripStartCommand: BaseCommand {
    public typealias TripStartCommandCompletion = ([Stop]?, Error?) -> Void
    public static let sharedInstance = TripStartCommand()

    public override init() {}

    public func tripStarts(forTransitMode sqlQuery: TransitMode, route _: Route, completion: @escaping TripStartCommandCompletion) {

        //        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
        //            var stops = [Stop]()
        //            for row in statement {
        //
        ////                if
        ////                    let col0 = row[0], let stopId = col0 as? Int64,
        ////                    let col1 = row[1], let stopName = col1 as? String,
        ////                    let col2 = row[2], let stopLatitudeString = col2 as? String, let stopLatitude = Double(stopLatitudeString),
        ////                    let col3 = row[3], let stopLongitudeString = col3 as? String, let stopLongitude = Double(stopLongitudeString),
        ////                    let col4 = row[4], let wheelchairBoardingInt = col4 as? Int64,
        ////                    let col5 = row[5], let directionCodeInt = col5 as? Int64, let directionCode = RouteDirectionCode(rawValue: Int(directionCodeInt)),
        ////                    let col6 = row[6], let directionString = col6 as? String {
        ////                    let wheelchairBoarding = wheelchairBoardingInt == 1
        ////                    let stop = Stop(stopId: Int(stopId), stopName: stopName,
        ////                                    stopLatitude: stopLatitude, stopLongitude: stopLongitude, wheelchairBoarding: wheelchairBoarding,
        ////                                    routeDirection: RouteDirection(directionCode: directionCode, directionString: directionString))
        ////                    stops.append(stop)
        //                }
        //            }
        //            return stops
        //        }
    }
}
