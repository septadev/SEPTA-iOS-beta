//
//  RoutesQuery.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public enum SQLRoutesQuery {
    case bus
    case rail
    case subway
    case trolley
    case nhsl

    var sqlBindings: [[String]] {
        return [[String]]()
    }

    var fileName: String {
        switch self {
        case .bus: return "busRoute"
        case .rail: return "railRoute"
        case .subway: return "subwayRoute"
        case .trolley: return "trollyRoute"
        case .nhsl: return "NHSL Route"
        }
    }
}
