//
//  FilterableRoute.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct FilterableRoute {
    let filterString: String
    var filterstringComponents: [String] {
        return filterString.components(separatedBy: " ")
    }

    let sortString: String
    let route: Route

    static var routeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0000"
        return formatter
    }()

    init(route: Route) {
        if let routeInt = Int(route.routeId), let routeString = FilterableRoute.routeNumberFormatter.string(from: NSNumber(value: routeInt)) {
            sortString = routeString + String(route.routeDirectionCode.rawValue)
        } else {
            sortString = "z\(route.routeId)"
        }
        filterString = (route.routeId + " " + route.routeShortName).lowercased()
        self.route = route
    }
}
