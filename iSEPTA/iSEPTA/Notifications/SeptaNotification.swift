//
//  SeptaNotification.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

enum NotificationType: String, Codable, Equatable {
    case specialAnnouncement = "SPECIAL_ANNOUNCEMENT"
    case detour = "DETOUR"
    case alert = "ALERT"
    case delay = "DELAY"

    init?(info: Payload) {
        guard let notificationTypeString = info[Keys.notficationType] as? String,
            let notificationType = NotificationType(rawValue: notificationTypeString) else { return nil }
        self = notificationType
    }
}

protocol SeptaNotification {}

enum AlertDetourType: String, Codable {
    case detour = "DETOUR"
    case alert = "ALERT"
}

struct SeptaAlertDetourNotification: Codable, Equatable, SeptaNotification {
    let routeId: String
    let transitMode: TransitMode

    init?(info: Payload) {
        guard let routeId = info[Keys.routeIdKey] as? String,
            let routeType = info[Keys.routeTypeKey] as? String,
            let transitMode = TransitMode.fromNotificationRouteType(routeType: routeType) else { return nil }
        self.routeId = routeId
        self.transitMode = transitMode
    }
}

struct SeptaDelayNotification: Codable, Equatable, SeptaNotification {
    let routeId: String
    let transitMode: TransitMode
    let destinationStopId: String
    let vehicleId: String
    let delayType: DelayType

    init?(info: Payload) {
        guard let routeId = info[Keys.routeIdKey] as? String,
            let routeType = info[Keys.routeTypeKey] as? String,
            let transitMode = TransitMode.fromNotificationRouteType(routeType: routeType),
            let vehicleId = info[Keys.vehicleIdKey] as? String,
            let delayTypeString = info[Keys.delayTypeKey] as? String,
            let delayType = DelayType(rawValue: delayTypeString) else { return nil }
        let destinationStopId = info[Keys.destinationStopIdKey] as? String ?? ""
        
        self.routeId = routeId
        self.transitMode = transitMode
        self.destinationStopId = destinationStopId
        self.vehicleId = vehicleId
        self.delayType = delayType
    }
}

fileprivate struct Keys {
    static let notficationType = "notificationType"
    static let messageKey = "message"
    static let routeIdKey = "routeId"
    static let routeTypeKey = "routeType"
    static let destinationStopIdKey = "destinationStopId"
    static let vehicleIdKey = "vehicleId"
    static let delayTypeKey = "delayType"
    static let expiresKey = "expires"
}

enum DelayType: String, Codable, Equatable {
    case actual = "ACTUAL"
    case estimated = "ESTIMATED"
}
