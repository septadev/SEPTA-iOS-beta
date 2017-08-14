// Septa. 2017

import Foundation

public class RoutesCommand: BaseCommand {
    public typealias RouteCommandCompletion = ([Route]?, Error?) -> Void
    public static let sharedInstance = RoutesCommand()

    public override init() {}

    public func routes(forTransitMode sqlQuery: TransitMode, completion: @escaping RouteCommandCompletion) {

        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Route] in
            var routes = [Route]()
            for row in statement {
                if
                    let col0 = row[0], let routeId = col0 as? String,
                    let col1 = row[1], let routeShortName = col1 as? String,
                    let col2 = row[2], let routeLongName = col2 as? String,
                    let col3 = row[3], let dircode = col3 as? String,
                    let dircodeInt = Int(dircode),
                    let routeDirectionCode = RouteDirectionCode(rawValue: dircodeInt) {
                    let route = Route(routeId: routeId, routeShortName: routeShortName, routeLongName: routeLongName, routeDirectionCode: routeDirectionCode)
                    routes.append(route)
                }
            }
            return routes
        }
    }
}
