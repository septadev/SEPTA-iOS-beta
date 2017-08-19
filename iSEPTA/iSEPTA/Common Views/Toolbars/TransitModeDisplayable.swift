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

    public static func displayOrder() -> [TransitMode] {
        return [.bus, .rail, .subway, .nhsl, .trolley]
    }
}
