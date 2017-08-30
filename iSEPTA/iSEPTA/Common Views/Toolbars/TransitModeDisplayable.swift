//
//  TransitModeDisplayable.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

func == (lhs: TransitMode, rhs: TransitMode) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

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

    public func selectRoutePlaceholderText() -> String {
        switch self {
        case .rail: return "Select Line"
        default: return "Select Route"
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

    public func cellImage(routeId: String) -> UIImage? {
        switch self {
        case .bus: return UIImage(named: "busCell")
        case .rail: return UIImage(named: "railCell")
        case .subway:
            switch routeId {
            case "MFO", "BSO": return UIImage(named: "busCell")
            case "MFL": return UIImage(named: "MFLCell")
            case "BSL": return UIImage(named: "BSLCell")
            default: return nil
            }

        case .trolley: return UIImage(named: "trolleyCell")
        case .nhsl: return UIImage(named: "nhslCell")
        }
    }

    public static func displayOrder() -> [TransitMode] {
        return [.bus, .rail, .subway, .nhsl, .trolley]
    }

    public func colorForPill() -> UIColor? {
        switch self {
        case .rail: return nil
        case .subway : return nil
        case .bus: return SeptaColor.busColor
        case .trolley :return SeptaColor.trolleylColor
        case .nhsl: return SeptaColor.nhslColor
        }
    }

    public static func convertFromTransitMode(_ type: String) -> TransitMode? {
        let transitMode: TransitMode? = {
            switch type {
            case "RAIL":
                return .rail
            case "BUS":
                return .bus
            case "TROLLEY":
                return .trolley
            case "SUBWAY":
                return .subway
            case "NHSL":
                return .nhsl

            default: return nil
            }
        }()
        return transitMode
    }
}
