//
//  Route+Color.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

extension Route {

    func colorForRoute() -> UIColor? {
        switch routeId {
        case "AIR": return SeptaColor.AIR_RailLineColor
        case "CHE": return SeptaColor.CHE_RailLineColor
        case "CHW": return SeptaColor.CHW_RailLineColor
        case "LAN": return SeptaColor.LAN_RailLineColor
        case "MED": return SeptaColor.MED_RailLineColor
        case "FOX": return SeptaColor.FOX_RailLineColor
        case "NOR": return SeptaColor.NOR_RailLineColor
        case "PAO": return SeptaColor.PAO_RailLineColor
        case "CYN": return SeptaColor.CYN_RailLineColor
        case "TRE": return SeptaColor.TRE_RailLineColor
        case "WAR": return SeptaColor.WAR_RailLineColor
        case "WIL": return SeptaColor.WIL_RailLineColor
        case "WTR": return SeptaColor.WTR_RailLineColor
        case "GC": return SeptaColor.GC_RailLineColor

        case "MFO", "BSO": return SeptaColor.busColor
        case "MFL": return SeptaColor.mflColor
        case "BSL": return SeptaColor.bslColor

        default: return nil
        }
    }
}
