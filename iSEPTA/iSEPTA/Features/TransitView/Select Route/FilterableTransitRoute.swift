//
//  FilterableTransitRoute.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct FilterableTransitRoute {
    let filterString: String
    var filterstringComponents: [String] {
        return filterString.components(separatedBy: " ")
    }
    
    let sortString: String
    let route: TransitRoute
    
    static var routeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0000"
        return formatter
    }()
    
    init(route: TransitRoute) {
        if let routeInt = Int(route.routeId), let routeString = FilterableTransitRoute.routeNumberFormatter.string(from: NSNumber(value: routeInt)) {
            sortString = routeString
        } else {
            sortString = "z\(route.routeId)"
        }
        filterString = (route.routeId + " " + route.routeName).lowercased()
        self.route = route
    }
}
