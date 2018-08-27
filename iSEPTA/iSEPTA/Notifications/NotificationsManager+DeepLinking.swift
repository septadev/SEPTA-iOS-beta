//
//  NotificationsManager+DeepLinking.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension NotificationsManager {
    static func handleTap(info: PayLoad) {
        guard let notificationTypeString = info[Keys.notificationTypeKey] as? String,
            let notificationType = NotificationType(rawValue: notificationTypeString) else { return }

        switch notificationType {
        case .alert, .detour:
            guard let alertDetourNotification = decodeAlertDetourNotification(info: info) else { return }
            navigateToAlertDetails(notification: alertDetourNotification)
        case .delay:
            guard let delayNotification = decodeDelayNotification(info: info) else { return }
            navigateToNextToArrive(notification: delayNotification)
        default:
            break
        }
    }

    static func decodeAlertDetourNotification(info: PayLoad) -> SeptaAlertDetourNotification? {
        guard let routeId = info["routeId"] as? String,
            let routeType = info["routeType"] as? String,
            let mode = TransitMode.fromNotificationRouteType(routeType: routeType) else { return nil }

        return SeptaAlertDetourNotification(routeId: routeId, transitMode: mode)
    }

    static func navigateToAlertDetails(notification: SeptaAlertDetourNotification) {
        let action = NavigateToAlertDetailsFromNotification(notification: notification)
        store.dispatch(action)
    }

    static func decodeDelayNotification(info: PayLoad) -> SeptaDelayNotification? {
        guard let data = info[Keys.notificationKey] as? Data,
            let delayNotification = try? decoder.decode(SeptaDelayNotification.self, from: data) else { return nil }
        return delayNotification
    }

    static func navigateToNextToArrive(notification: SeptaDelayNotification) {
        let action = NavigateToNextToArriveFromDelayNotification(notification: notification)
        store.dispatch(action)
    }
}
