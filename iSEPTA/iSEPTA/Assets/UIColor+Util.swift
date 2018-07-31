//
//  UIColor+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    static func toPercent(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / CGFloat(255.0),
                       green: CGFloat(g) / CGFloat(255.0),
                       blue: CGFloat(b) / CGFloat(255.0),
                       alpha: a)
    }

    func septaColor() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        var result = "UNKNOWN Color"
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let iRed = Int(red * 255.0)
            let iGreen = Int(green * 255.0)
            let iBlue = Int(blue * 255.0)
            let iAlpha = Int(alpha * 255)

            switch (iRed, iGreen, iBlue, iAlpha) {
            case (34, 83, 145, 1): result = "navBarBlue"
            case (132, 162, 194, 1): result = "enabledCellBorder"
            case (103, 142, 195, 1): result = "transitViewRouteCardDividerBlue"
            case (78, 158, 244, 1): result = "transitViewActiveRoute"
            case (151, 151, 151, 1): result = "transitViewInactiveRoute"
            case (20, 75, 136, 1): result = "segmentBlue"
            case (132, 162, 194, 1): result = "subSegmentBlue"
            case (157, 66, 149, 1): result = "nhslColor"
            case (65, 82, 92, 1): result = "busColor"
            case (245, 130, 32, 1): result = "bslColor"
            case (65, 135, 199, 1): result = "mflColor"
            case (32, 114, 0, 1): result = "trolleylColor"
            case (148, 78, 111, 1): result = "railColor"
            case (144, 74, 111, 1): result = "AIR_RailLineColor"
            case (153, 118, 56, 1): result = "CHE_RailLineColor"
            case (58, 189, 178, 1): result = "CHW_RailLineColor"
            case (123, 93, 73, 1): result = "LAN_RailLineColor"
            case (50, 125, 201, 1): result = "MED_RailLineColor"
            case (246, 133, 65, 1): result = "FOX_RailLineColor"
            case (235, 67, 102, 1): result = "NOR_RailLineColor"
            case (41, 134, 91, 1): result = "PAO_RailLineColor"
            case (112, 84, 166, 1): result = "CYN_RailLineColor"
            case (243, 125, 196, 1): result = "TRE_RailLineColor"
            case (248, 179, 68, 1): result = "WAR_RailLineColor"
            case (153, 211, 104, 1): result = "WIL_RailLineColor"
            case (77, 85, 176, 1): result = "WTR_RailLineColor"
            case (156, 153, 210, 1): result = "GC_RailLineColor"
            case (215, 46, 18, 1): result = "transitIsLate"
            case (83, 158, 0, 1): result = "transitOnTime"
            case (117, 117, 117, 1): result = "transitIsScheduled"
            case (222, 222, 222, 1): result = "departingOnTime"
            case (222, 222, 222, 1): result = "departingBoundaryOnTime"
            case (217, 43, 0, 1): result = "departingBoundaryLate"
            case (34, 83, 145, 1): result = "editFavoriteBlue"
            case (230, 230, 230, 1): result = "buttonHighlight"
            case (235, 240, 245, 1): result = "twitterBackground"
            case (173, 207, 244, 1): result = "stopOrderButtonBlue"
            case (27, 78, 142, 1): result = "blue_27_78_142"
            case (198, 198, 198, 1): result = "blue_27_78_142"
            default: break
            }
        }
        return result
    }
}
