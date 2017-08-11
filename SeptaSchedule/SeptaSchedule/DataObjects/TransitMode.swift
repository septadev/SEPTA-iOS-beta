//
//  TransitMode.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

import Foundation

public enum TransitMode: String, Codable {
    case bus
    case rail
    case subway
    case nhsl
    case trolley

    public var routeTitle: String {
        switch self {
        case .bus: return "Bus Routes"
        case .rail: return "Regional Rail Routes"
        case .subway: return "Subway Routes"
        case .nhsl: return "NHSL Routes"
        case .trolley: return "Trolley Routes"
        }
    }
}
