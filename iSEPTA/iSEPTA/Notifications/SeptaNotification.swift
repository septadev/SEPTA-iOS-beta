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

    init?(info: PayLoad) {
        guard let notificationTypeString = info[Keys.notficationType] as? String,
            let notificationType = NotificationType(rawValue: notificationTypeString) else { return nil }
        self = notificationType
    }
}

protocol SeptaNotification {
    var message: String { get }
    var expires: Date { get }

    var title: String { get }
}

enum AlertDetourType: String, Codable {
    case detour = "DETOUR"
    case alert = "ALERT"
}

struct SeptaAlertDetourNotification: Codable, Equatable, SeptaNotification {
    let message: String
    let routeId: String
    let transitMode: TransitMode
    let expires: Date
    let alertDetourType: AlertDetourType
    var title: String {
        switch alertDetourType {
        case .alert: return "Service Alert for Route \(routeId)"
        case .detour: return "Detour on Route \(routeId)"
        }
    }

    init?(info: PayLoad) {
        guard let message = info[Keys.messageKey] as? String,
            let routeId = info[Keys.routeIdKey] as? String,
            let routeType = info[Keys.routeTypeKey] as? String,
            let transitMode = TransitMode.fromNotificationRouteType(routeType: routeType),
            let expiresString = info[Keys.expiresKey] as? String,
            let expiresDate = DateFormatters.networkFormatter.date(from: expiresString),
            Date() < expiresDate,
            let notificationTypeString = info[Keys.notficationType] as? String,
            let alertDetourType = AlertDetourType(rawValue: notificationTypeString) else { return nil }
        self.message = message
        self.routeId = routeId
        self.transitMode = transitMode
        expires = expiresDate
        self.alertDetourType = alertDetourType
    }
}

struct SeptaSpecialAnnouncementNotification: Codable, Equatable, SeptaNotification {
    let message: String
    let expires: Date

    var title: String {
        return "Special Announcement"
    }

    init?(info: PayLoad) {
        guard let message = info[Keys.messageKey] as? String,
            let expiresString = info[Keys.expiresKey] as? String,
            let expiresDate = DateFormatters.networkFormatter.date(from: expiresString),
            Date() < expiresDate else { return nil }
        self.message = message
        expires = expiresDate
    }
}

struct SeptaDelayNotification: Codable, Equatable, SeptaNotification {
    let message: String
    let routeId: String
    let transitMode: TransitMode
    let destinationStopId: String
    let vehicleId: String
    let delayType: DelayType
    let expires: Date

    var title: String {
        return "Train Delay on \(routeId)"
    }

    init?(info: PayLoad) {
        guard let message = info[Keys.messageKey] as? String,
            let routeId = info[Keys.routeIdKey] as? String,
            let routeType = info[Keys.routeTypeKey] as? String,
            let transitMode = TransitMode.fromNotificationRouteType(routeType: routeType),
            let destinationStopId = info[Keys.destinationStopIdKey] as? String,
            let vehicleId = info[Keys.vehicleIdKey] as? String,
            let delayTypeString = info[Keys.delayTypeKey] as? String,
            let delayType = DelayType(rawValue: delayTypeString),
            let expiresString = info[Keys.expiresKey] as? String,
            let expiresDate = DateFormatters.networkFormatter.date(from: expiresString),
            Date() < expiresDate else { return nil }
        self.message = message
        self.routeId = routeId
        self.transitMode = transitMode
        self.destinationStopId = destinationStopId
        self.vehicleId = vehicleId
        self.delayType = delayType
        expires = expiresDate
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
