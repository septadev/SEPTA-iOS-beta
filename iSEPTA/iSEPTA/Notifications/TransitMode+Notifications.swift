//
//  TransitMode+Notifications.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

import SeptaSchedule

extension TransitMode {
    static func fromNotificationRouteType(routeType: String) -> TransitMode? {
        switch routeType {
        case "RAIL": return .rail
        case "BUS": return .bus
        case "TROLLEY": return .trolley
        case "SUBWAY": return .subway
        case "NHSL": return .nhsl

        default: return nil
        }
    }
}
