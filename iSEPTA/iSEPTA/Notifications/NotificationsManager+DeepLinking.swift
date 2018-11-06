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
    static func handleTap(info: Payload) {
        guard let notificationTypeString = info[Keys.notificationTypeKey] as? String,
            let notificationType = NotificationType(rawValue: notificationTypeString) else { return }

        switch notificationType {
        case .alert, .detour:
            guard let alertDetourNotification = decodeAlertDetourNotification(info: info) else { return }
            navigateToAlertDetails(notification: alertDetourNotification)
        case .delay:
            guard let delayNotification = decodeDelayNotification(info: info) else { return }
            if delayNotification.delayType == .actual {
                // TODO: JJ might still be valid
                //navigateToNextToArrive(notification: delayNotification)
                let newRequest = TripDetailsRequestURLSession()
                newRequest.sendRequestRealTimeTripsDetails(notification: delayNotification)
            }
        default:
            break
        }
    }

    static func decodeAlertDetourNotification(info: Payload) -> SeptaAlertDetourNotification? {
        return SeptaAlertDetourNotification(info: info)
    }

    static func navigateToAlertDetails(notification: SeptaAlertDetourNotification) {
        let action = NavigateToAlertDetailsFromNotification(notification: notification)
        store.dispatch(action)
    }

    static func decodeDelayNotification(info: Payload) -> SeptaDelayNotification? {
        return SeptaDelayNotification(info: info)
    }

    static func navigateToNextToArrive(notification: SeptaDelayNotification) {
        let action = NavigateToNextToArriveFromDelayNotification(notification: notification)
        store.dispatch(action)
    }
}
