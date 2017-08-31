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

        if transitMode == .bus {
            return "\(routeId): \(routeShortName)"
        }
        switch routeId {

        case "BSL": return "Broad Street Line"
        case "BSO": return "Broad Street Overnight"
        case "MFL": return "Market Frankfort Line"
        case "MFO": return "Market Frankfort Overnight"
        case "NHSL": return "Norristown High Speed Line"
        default: return nil
        }
    }
}
