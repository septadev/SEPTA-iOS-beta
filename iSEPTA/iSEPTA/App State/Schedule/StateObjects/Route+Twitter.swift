//
//  Route+Twitter.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension Route {
    public static func twiterHandleForRouteId(routeId: String, transitMode: TransitMode) -> String? {

        if transitMode == .bus {
            return "@SEPTA_Bus"
        }

        if transitMode == .trolley {
            switch routeId {
            case "10": return "@SEPTA_TRL_10"
            case "11": return "@SEPTA_TRL_11"
            case "13": return "@SEPTA_TRL_13"
            case "15": return "@SEPTA_TRL_15"
            case "34": return "@SEPTA_TRL_34"
            case "36": return "@SEPTA_TRL_36"
            case "101": return "@SEPTA_TRL_101"
            case "102": return "@SEPTA_TRL_102"
            default: return "@SEPTANews"
            }
        }

        if transitMode == .rail {
            switch routeId {
            case "AIR": return "@SEPTA_AIR"
            case "CHE": return "@SEPTA_CHE"
            case "CHW": return "@SEPTA_CHW"
            case "CYN": return "@SEPTA_CYN"
            case "FOX": return "@SEPTA_FOX"
            case "DOY": return "@SEPTA_DOY"
            case "NOR": return "@SEPTA_NOR"
            case "ELW": return "@SEPTA_ELW"
            case "PAO": return "@SEPTA_PAO"
            case "TRE": return "@SEPTA_TRE"
            case "WAR": return "@SEPTA_WAR"
            case "WTR": return "@SEPTA_WTR"
            case "WIL": return "@SEPTA_WIL"
            default: return "@SEPTANews"
            }
        }
        switch routeId {

        case "BSL": return "@SEPTA_BSL"
        case "BSO": return "@SEPTA_Bus"
        case "MFL": return "@SEPTA_MFL"
        case "MFO": return "@SEPTA_Bus"
        case "NHSL": return "@SEPTA_NHSL"
        default: return nil
        }
    }
}
