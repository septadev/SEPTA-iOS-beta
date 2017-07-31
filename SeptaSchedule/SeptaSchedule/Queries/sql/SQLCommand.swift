// SEPTA.org, created on 7/31/17.

import Foundation
import SQLite

enum SQLCommandError: Error {
    case noConnection
    case noCommand
}

class SQLCommand {
    typealias StopCompletion = ([Stop]?, Error?) -> Void

    func busDestinationBeginStops(routeId _: Int, scheduleType _: ScheduleType, completion: @escaping StopCompletion) {

        DispatchQueue.global(qos: .userInitiated).async {
            let commandStrings = SQLCommandStrings()
            var cmdError: Error?
            var stops = [Stop]()
            do {
                guard let conn = try SQLConnection.sqlConnection() else { throw SQLCommandError.noConnection }
                guard let cmd = try commandStrings.commandStringForFileName(.busStart) else { throw SQLCommandError.noCommand }

                let stmt = try conn.prepare(cmd)
                for row in stmt {
                    if let col0 = row[0], let stopId = col0  as? Int64, let col1 = row[1], let stopName = col1 as? String {

                        
                        stops.append(Stop(stopId: stopId, stopName: stopName))
                    }
                }
            } catch {
                cmdError = error
            }

            DispatchQueue.main.async {
                completion(stops, cmdError)
            }
        }
    }
}
