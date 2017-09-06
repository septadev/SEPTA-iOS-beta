//
//  AllRoutes.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension Route {
    static func allRailRoutesRouteId() -> String { return "allRailRoutes" }
    public static func allRailRoutesRoute() -> Route {
        return Route(routeId: Route.allRailRoutesRouteId(), routeShortName: "all", routeLongName: "all", routeDirectionCode: .inbound)
    }
}
