//
//  RoutesCommands.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class RoutesCommand: BaseCommand {
    public typealias RouteCommandCompletion = ([Route]?, Error?) -> Void
    public static let sharedInstance = RoutesCommand()

    public override init() {}

    public func routes(forTransitMode sqlQuery: TransitMode, completion: @escaping RouteCommandCompletion) {

        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Route] in
            var routes = [Route]()
            for row in statement {

                let routeId: String?
                // in the database, route_id is defined as an Int, but there are strings in there.
                if let col0 = row[0] {
                    if let routeIdString = col0 as? String {
                        routeId = routeIdString
                    } else if let routeIdInt = col0 as? Int64 {
                        routeId = String(routeIdInt)
                    } else {
                        routeId = nil
                    }
                } else {
                    routeId = nil
                }

                if
                    let routeId = routeId,
                    let col1 = row[1], let routeShortName = col1 as? String,
                    let col2 = row[2], let routeLongName = col2 as? String {
                    let route = Route(routeId: routeId, routeShortName: routeShortName, routeLongName: routeLongName)
                    routes.append(route)
                }
            }
            return routes
        }
    }
}
