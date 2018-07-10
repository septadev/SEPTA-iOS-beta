//
//  TransitRoutesCommand.swift
//  SeptaSchedule
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

public class TransitRoutesCommand: BaseCommand {
    
    public typealias TransitRoutesCommandCompletion = ([TransitRoute]?, Error?) -> Void
    public static let sharedInstance = TransitRoutesCommand()
    
    public func routes(completion: @escaping TransitRoutesCommandCompletion) {
        let sqlQuery = TransitRoutesSQLQuery()
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [TransitRoute] in
            var routes = [TransitRoute]()
            for row in statement {
                if
                    let col0 = row[0], let routeId = col0 as? String,
                    let col1 = row[1], let routeType = col1 as? String,
                    let col2 = row[2], let routeShortName = col2 as? String,
                    let col3 = row[3], let routeLongName = col3 as? String,
                    let col4 = row[4], let dircode = col4 as? String,
                    let dircodeInt = Int(dircode),
                    let routeDirectionCode = RouteDirectionCode(rawValue: dircodeInt) {
                    let route = TransitRoute(routeId: routeId, routeType: routeType, routeShortName: routeShortName, routeLongName: routeLongName, routeDirectionCode: routeDirectionCode)
                    routes.append(route)
                }
            }
            return routes
        }
    }
}
