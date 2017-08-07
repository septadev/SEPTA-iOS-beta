//
//  TransitMode.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum TransitMode: String {
    case bus
    case rail
    case subway
    case nhsl
    case trolley

    var routeTitle: String {
        switch self {
        case .bus: return "Bus Routes"
        case .rail: return "Regional Rail Routes"
        case .subway: return "Subway Routes"
        case .nhsl: return "NHSL Routes"
        case .trolley: return "Trolley Routes"
        }
    }
}
