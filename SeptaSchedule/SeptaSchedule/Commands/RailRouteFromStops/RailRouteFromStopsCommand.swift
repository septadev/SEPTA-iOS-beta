//
//  RailRoutFromStopsCommand.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//
import Foundation

public class RailRouteFromStopsCommand: BaseCommand {
    public typealias RouteCommandCompletion = ([Route]?, Error?) -> Void
    public static let sharedInstance = RailRouteFromStopsCommand()

    public override init() {}

    public func routes(routeId: String, startStopId: Int, endStopId: Int, completion: @escaping RouteCommandCompletion) {
        let sqlQuery = RailRoutesFromStopsSQLQuery(routeId: routeId, startStopId: startStopId, endStopId: endStopId)
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
