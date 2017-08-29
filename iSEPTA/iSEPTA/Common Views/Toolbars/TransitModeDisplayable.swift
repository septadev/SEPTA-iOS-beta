//
//  TransitModeDisplayable.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension TransitMode {

    func imageName() -> String {

        switch self {
        case .bus:
            return "busFinalIconWhite"
        case .rail:
            return "railFinalIconWhite"
        case .trolley:
            return "trolleyFinalIconWhite"
        case .nhsl:
            return "nhslFinalIconWhite"
        case .subway:
            return "subwayFinalIconWhite"
        }
    }

    func highlightedImageName() -> String {

        switch self {
        case .bus:
            return "busActiveFinal"
        case .rail:
            return "railActiveFinal"
        case .trolley:
            return "trolleyActiveFinal"
        case .nhsl:
            return "nhslActiveFinal"
        case .subway:
            return "subwayActiveFinal"
        }
    }

    public func routeTitle() -> String {
        switch self {
        case .bus: return "Bus Route"
        case .rail: return "Rail Line"
        case .subway: return "Subway Line"
        case .nhsl: return "NHSL Line"
        case .trolley: return "Trolley Line"
        }
    }

    public func name() -> String {
        switch self {
        case .bus: return "Bus"
        case .rail: return "Rail"
        case .subway: return "Subway"
        case .nhsl: return "NHSL"
        case .trolley: return "Trolley"
        }
    }

    public func scheduleName() -> String {
        switch self {
        case .bus: return "Bus Schedules"
        case .rail: return "Regional Rail Schedules"
        case .subway: return "Subway Schedules"
        case .nhsl: return "NHSL Schedules"
        case .trolley: return "Trolley Schedules"
        }
    }

    public func selector() -> String {
        switch self {
        case .rail: return "Select Line"
        default: return "Select Stop"
        }
    }

    public func startingStopName() -> String {
        switch self {
        case .rail: return "Starting Station"
        default: return "Starting Stop"
        }
    }

    public func endingStopName() -> String {
        switch self {
        case .rail: return "Destination Station"
        default: return "Destination Stop"
        }
    }

    public func placeholderText() -> String {
        switch self {
        case .rail: return "Type the station name or select"
        default: return "Type the stop name or select"
        }
    }

    public func routePlaceholderText() -> String {
        switch self {
        case .rail: return "Type the line name or select"
        default: return "Type the bus route name or select"
        }
    }

    public func addressSearchPrompt() -> String {
        switch self {
        case .rail: return "Select Nearby Station"
        default: return "Select Nearby Stop"
        }
    }

    public static func displayOrder() -> [TransitMode] {
        return [.bus, .rail, .subway, .nhsl, .trolley]
    }
}
