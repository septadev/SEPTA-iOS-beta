//
//  HolidayForDateSQLQuery.swift
//  SeptaSchedule
//
//  Created by James Johnson on 01/07/2019.
//  Copyright © 2019 Mark Broski. All rights reserved.
//

import Foundation

class HolidayForDateSQLQuery: SQLQueryProtocol {
    let transitMode: TransitMode

    var sqlBindings: [[String]] {
        switch transitMode {
        case .rail:
            return [[":table_name", "holiday_rail"]]
        default:
            return [[":table_name", "holiday_bus"]]
        }
    }

    var fileName: String {
        return "confirmholiday"
    }
    
    init(transitMode: TransitMode) {
        self.transitMode = transitMode
    }

}
