//
//  SeptaNotification.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct SeptaNotification: Codable, Equatable {
    let type: NotificationType?
    let routeId: String?
    let message: String?
    let routeType: RouteType?
    let vehicleId: String?
    let destinationStopId: String?
    let delayType: DelayType?
    let expires: Date?

    init(payload: [AnyHashable: Any]) {
        let typeString = payload["notificationType"] as? String ?? ""
        type = NotificationType(rawValue: typeString)
        routeId = payload["routeId"] as? String
        message = payload["message"] as? String
        let routeTypeString = payload["routeType"] as? String ?? ""
        routeType = RouteType(rawValue: routeTypeString)
        vehicleId = payload["vehicleId"] as? String
        destinationStopId = payload["destinationStopId"] as? String
        let delayTypeString = payload["delayType"] as? String ?? ""
        delayType = DelayType(rawValue: delayTypeString)
        let dateString = payload["expires"] as? String ?? ""
        expires = SeptaNotification.dateFrom(dateString)
    }

    static func dateFrom(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"

        // Strip out milliseconds
        var adjustedDateString = ""
        if let decimalIndex = dateString.index(of: "."), let plusIndex = dateString.index(of: "+") {
            adjustedDateString = "\(dateString[..<decimalIndex])\(dateString[plusIndex...])"
        }

        return dateFormatter.date(from: adjustedDateString)
    }
}

enum NotificationType: String, Codable, Equatable {
    case specialAnnouncement = "SPECIAL_ANNOUNCEMENT"
    case detour = "DETOUR"
    case alert = "ALERT"
    case delay = "DELAY"
}

enum RouteType: String, Codable, Equatable {
    case rail = "RAIL"
    case bus = "BUS"
    case trolley = "TROLLEY"
    case subway = "SUBWAY"
    case nhsl = "NHSL"
}

enum DelayType: String, Codable, Equatable {
    case actual = "ACTUAL"
    case estimated = "ESTIMATED"
}
