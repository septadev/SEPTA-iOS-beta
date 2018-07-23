//
//  Route+Title.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/31/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension Route {
    public func shortNameOverrideForRoute(transitMode: TransitMode) -> String? {
        switch transitMode {
        case .bus, .trolley:
            return "\(routeId): \(routeShortName)"
        default:
            break
        }

        switch routeId {
        case "BSL": return "Broad Street Line"
        case "BSO": return "Broad Street Overnight"
        case "MFL": return "Market Frankford Line"
        case "MFO": return "Market Frankford Overnight"
        case "NHSL": return "Norristown High Speed Line"
        default: return nil
        }
    }
}
