// SEPTA.org, created on 7/31/17.

import Foundation
import SQLite

enum SQLCommandError: Error {
    case noConnection
    case noCommand
}

class BusCommands: BaseCommand {
    typealias completion = ([Stop]?, Error?) -> Void

    func busStops(withQuery sqlQuery: SQLQuery, completion: @escaping completion) {

        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Stop] in
            var stops = [Stop]()
            for row in statement {
                if let col0 = row[0], let stopId = col0 as? Int64, let col1 = row[1], let stopName = col1 as? String {
                    stops.append(Stop(stopId: stopId, stopName: stopName))
                }
            }
            return stops
        }
    }
}
