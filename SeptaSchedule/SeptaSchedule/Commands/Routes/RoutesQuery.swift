//
//  RoutesQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension TransitMode: SQLQueryProtocol {

    var sqlBindings: [[String]] {
        return [[String]]()
    }

    var fileName: String {
        switch self {
        case .bus: return "busRoute"
        case .rail: return "railRoute"
        case .subway: return "subwayRoute"
        case .trolley: return "trolleyRoute"
        case .nhsl: return "NHSLRoute"
        }
    }
}
