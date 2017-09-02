//
//  Route+Icon.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit
extension Route {

    public func iconForRoute() -> UIImage? {
        switch routeId {
        case "AIR": return UIImage(named: "AIR_Line")
        case "CHE": return UIImage(named: "CHE_Line")
        case "CHW": return UIImage(named: "CHW_Line")
        case "LAN": return UIImage(named: "LAN_Line")
        case "MED": return UIImage(named: "MED_Line")
        case "FOX": return UIImage(named: "FOX_Line")
        case "NOR": return UIImage(named: "NOR_Line")
        case "PAO": return UIImage(named: "PAO_Line")
        case "CYN": return UIImage(named: "CYN_Line")
        case "TRE": return UIImage(named: "TRE_Line")
        case "WAR": return UIImage(named: "WAR_Line")
        case "WIL": return UIImage(named: "WIL_Line")
        case "WTR": return UIImage(named: "WTR_Line")
        case "GC": return UIImage(named: "GC_Line")

        case "MFO", "BSO": return UIImage(named: "BUS_Line")
        case "MFL": return UIImage(named: "MF_Line")
        case "BSL": return UIImage(named: "BSL_Line")

        default: return nil
        }
    }

    func iconForRoute(transitMode: TransitMode) -> UIImage? {
        if let routeImage = self.iconForRoute() {
            return routeImage
        } else if let transitViewImage = transitMode.cellImage() {
            return transitViewImage
        }
        return nil
    }
}
