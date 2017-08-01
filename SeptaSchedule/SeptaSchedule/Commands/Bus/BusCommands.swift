// SEPTA.org, created on 7/31/17.

import Foundation
import SQLite

enum SQLCommandError: Error {
    case noConnection
    case noCommand
}

class BusCommands: BaseCommand {
    typealias BusStopsCompletion = ([Stop]?, Error?) -> Void
    typealias BusTripsCompletion = ([Trip]?, Error?) -> Void

    func busStops(withQuery sqlQuery: SQLQuery, completion: @escaping BusStopsCompletion) {

        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
            var stops = [Stop]()
            for row in statement {

                if
                    let col0 = row[0], let stopId = col0 as? Int64,
                    let col1 = row[1], let stopName = col1 as? String,
                    let col2 = row[2], let stopLatitudeString = col2 as? String, let stopLatitude = Double(stopLatitudeString),
                    let col3 = row[3], let stopLongitudeString = col3 as? String, let stopLongitude = Double(stopLongitudeString) {
                    let stop = Stop(stopId: Int(stopId), stopName: stopName, stopLatitude: stopLatitude, stopLongitude: stopLongitude, wheelchairBoarding: false)
                    stops.append(stop)
                }
            }
            return stops
        }
    }

    func busTrips(withQuery sqlQuery: SQLQuery, completion: @escaping BusTripsCompletion) {

        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Trip] in
            var trips = [Trip]()
            for row in statement {

                if
                    let col0 = row[0], let departure = col0 as? Int64,
                    let col1 = row[1], let arrival = col1 as? Int64 {
                    let trip = Trip(departureInt: Int(departure), arrivalInt: Int(arrival))
                    trips.append(trip)
                }
            }
            return trips
        }
    }
}
