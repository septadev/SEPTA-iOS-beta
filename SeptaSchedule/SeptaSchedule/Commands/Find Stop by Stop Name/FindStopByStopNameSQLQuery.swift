//
//  RailRouteFromStopsSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

class FindStopByStopNameSQLQuery: SQLQueryProtocol {
    let stopName: String

    public var sqlBindings: [[String]] {
        return [[":stop_name", stopName]]
    }

    public var fileName: String {
        return "railFindStopByStopName"
    }

    init(stopName: String) {
        self.stopName = stopName
    }
}
