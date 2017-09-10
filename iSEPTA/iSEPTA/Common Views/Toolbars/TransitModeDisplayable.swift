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

    public func vehicleNumberTitle() -> String {
        switch self {
        case .bus: return "Bus #"
        case .rail: return "Train #"
        case .subway: return "Train #"
        case .nhsl: return "Train #"
        case .trolley: return "Trolley #"
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

    public func cellImage() -> UIImage? {

        switch self {
        case .bus: return UIImage(named: "BUS_Line")
        case .rail: return nil
        case .subway: return nil
        case .trolley: return UIImage(named: "Trolley_Line")
        case .nhsl: return UIImage(named: "NHSL_Line")
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

    public func nextToArriveTitle() -> String {
        switch self {
        case .rail: return "Regional Rail"
        case .subway : return "Subway"
        case .bus: return "Bus"
        case .trolley :return "Trolley"
        case .nhsl: return "NHSL"
        }
    }

    public func nextToArriveDetailTitle() -> String {
        switch self {
        case .rail: return "Next to Arrive: Regional Rail"
        case .subway : return "Next to Arrive: Subway"
        case .bus: return "Next to Arrive: Bus"
        case .trolley :return "Next to Arrive: Trolley"
        case .nhsl: return "Next to Arrive: NHSL"
        }
    }

    public func nextToDetailTitle() -> String {
        switch self {
        case .rail: return "Next Trains To Arrive"
        case .subway : return "Next Trains to Arrive"
        case .bus: return "Next Buses to Arrive"
        case .trolley :return "Next Trolleys to Arrive"
        case .nhsl: return "Next Trains To Arrive"
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

    func mapPin() -> UIImage? {
        let imageName: String
        switch self {
        case .rail: imageName = "RailPin"
        case .subway : imageName = "SubwayPin"
        case .bus: imageName = "BusPin"
        case .trolley :imageName = "TrolleyPin"
        case .nhsl:imageName = "NHSLPin"
        }
        guard let image = UIImage(named: imageName), let cgImage = image.cgImage else { return nil }

        return UIImage(cgImage: cgImage, scale: 3, orientation: image.imageOrientation)
    }

    public func scheduleTypeSegments() -> [ScheduleType] {
        switch self {
        case .rail : return [.mondayThroughThursday, .friday, .saturday, .sunday]
        default:
            return [.weekday, .saturday, .sunday]
        }
    }

    public func defaultScheduleType() -> ScheduleType {
        switch self {
        case .rail : return .mondayThroughThursday
        default:
            return .weekday
        }
    }

    public static func currentTransitMode() -> TransitMode! {
        if store.state.targetForScheduleActions() == .schedules {
            return store.state.scheduleState.scheduleRequest.transitMode
        } else {
            return store.state.nextToArriveState.scheduleState.scheduleRequest.transitMode
        }
    }

    public static func defaultTransitMode() -> TransitMode {
        return .bus
    }
}
