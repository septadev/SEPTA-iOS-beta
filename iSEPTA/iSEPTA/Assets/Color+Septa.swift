// Septa. 2017

import Foundation
import UIKit

struct SeptaColor {
    static let disabledText = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    static let enabledText = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let navBarBlue = UIColor.toPercent(34, 83, 145, 1)
    static let white20 = UIColor.toPercent(255, 255, 255, 0.2)
    static let viewShadowColor = UIColor.toPercent(0, 0, 0, 0.2)
    static let navBarShadowColor = UIColor.toPercent(0, 0, 0, 0.41)
    static let enabledCellBorder = UIColor.toPercent(132, 162, 194, 1)
    static let transitViewRouteCardDividerBlue = UIColor.toPercent(103, 142, 195, 1)
    static let transitViewActiveRoute = UIColor.toPercent(78, 158, 244, 1)
    static let transitViewInactiveRoute = UIColor.toPercent(151, 151, 151, 1)

    static let segmentBlue = UIColor.toPercent(20, 75, 136, 1)
    static let subSegmentBlue = UIColor.toPercent(132, 162, 194, 1)

    static let nhslColor = UIColor.toPercent(157, 66, 149, 1)
    static let busColor = UIColor.toPercent(65, 82, 92, 1)
    static let bslColor = UIColor.toPercent(245, 130, 32, 1)
    static let mflColor = UIColor.toPercent(65, 135, 199, 1)
    static let trolleylColor = UIColor.toPercent(32, 114, 0, 1)
    static let railColor = UIColor.toPercent(148, 78, 111, 1)

    static let AIR_RailLineColor = UIColor.toPercent(144, 74, 111, 1)
    static let CHE_RailLineColor = UIColor.toPercent(153, 118, 56, 1)
    static let CHW_RailLineColor = UIColor.toPercent(58, 189, 178, 1)
    static let LAN_RailLineColor = UIColor.toPercent(123, 93, 73, 1)
    static let MED_RailLineColor = UIColor.toPercent(50, 125, 201, 1)
    static let FOX_RailLineColor = UIColor.toPercent(246, 133, 65, 1)
    static let NOR_RailLineColor = UIColor.toPercent(235, 67, 102, 1)
    static let PAO_RailLineColor = UIColor.toPercent(41, 134, 91, 1)
    static let CYN_RailLineColor = UIColor.toPercent(112, 84, 166, 1)
    static let TRE_RailLineColor = UIColor.toPercent(243, 125, 196, 1)
    static let WAR_RailLineColor = UIColor.toPercent(248, 179, 68, 1)
    static let WIL_RailLineColor = UIColor.toPercent(153, 211, 104, 1)
    static let WTR_RailLineColor = UIColor.toPercent(77, 85, 176, 1)
    static let GC_RailLineColor = UIColor.toPercent(156, 153, 210, 1)

    static let transitIsLate = UIColor.toPercent(215, 46, 18, 1)
    static let transitOnTime = UIColor.toPercent(83, 158, 0, 1)
    static let transitIsScheduled = UIColor.toPercent(117, 117, 117, 1)
    static let departingOnTime = UIColor.toPercent(222, 222, 222, 1)
    static let departingBoundaryOnTime = UIColor.toPercent(222, 222, 222, 1)
    static let departingBoundaryLate = UIColor.toPercent(217, 43, 0, 1)

    static let editFavoriteBlue = UIColor.toPercent(34, 83, 145, 1)

    static let buttonHighlight = UIColor.toPercent(230, 230, 230, 1)

    static let twitterBackground = UIColor.toPercent(235, 240, 245, 1)

    static let stopOrderButtonBlue = UIColor.toPercent(173, 207, 244, 1)

    static let black87 = UIColor.toPercent(0, 0, 0, 0.87)
    static let blue_27_78_142 = UIColor.toPercent(27, 78, 142, 1)
    static let gray_198 = UIColor.toPercent(198, 198, 198, 1)

    static func colorFromString(_ string: String) -> UIColor {
        switch string {
        case "disabledText": return disabledText
        case "enabledText": return enabledText
        case "navBarBlue": return navBarBlue
        case "white20": return white20
        case "viewShadowColor": return viewShadowColor
        case "navBarShadowColor": return navBarShadowColor
        case "enabledCellBorder": return enabledCellBorder
        case "transitViewRouteCardDividerBlue": return transitViewRouteCardDividerBlue
        case "transitViewActiveRoute": return transitViewActiveRoute
        case "transitViewInactiveRoute": return transitViewInactiveRoute
        case "segmentBlue": return segmentBlue
        case "subSegmentBlue": return subSegmentBlue
        case "nhslColor": return nhslColor
        case "busColor": return busColor
        case "bslColor": return bslColor
        case "mflColor": return mflColor
        case "trolleylColor": return trolleylColor
        case "railColor": return railColor
        case "AIR_RailLineColor": return AIR_RailLineColor
        case "CHE_RailLineColor": return CHE_RailLineColor
        case "CHW_RailLineColor": return CHW_RailLineColor
        case "LAN_RailLineColor": return LAN_RailLineColor
        case "MED_RailLineColor": return MED_RailLineColor
        case "FOX_RailLineColor": return FOX_RailLineColor
        case "NOR_RailLineColor": return NOR_RailLineColor
        case "PAO_RailLineColor": return PAO_RailLineColor
        case "CYN_RailLineColor": return CYN_RailLineColor
        case "TRE_RailLineColor": return TRE_RailLineColor
        case "WAR_RailLineColor": return WAR_RailLineColor
        case "WIL_RailLineColor": return WIL_RailLineColor
        case "WTR_RailLineColor": return WTR_RailLineColor
        case "GC_RailLineColor": return GC_RailLineColor
        case "transitIsLate": return transitIsLate
        case "transitOnTime": return transitOnTime
        case "transitIsScheduled": return transitIsScheduled
        case "departingOnTime": return departingOnTime
        case "departingBoundaryOnTime": return departingBoundaryOnTime
        case "departingBoundaryLate": return departingBoundaryLate
        case "editFavoriteBlue": return editFavoriteBlue
        case "buttonHighlight": return buttonHighlight
        case "twitterBackground": return twitterBackground
        case "stopOrderButtonBlue": return stopOrderButtonBlue
        case "black87": return black87
        case "blue_27_78_142": return blue_27_78_142
        default: return UIColor.black
        }
    }
}
