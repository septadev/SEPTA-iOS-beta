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
            guard let data = info[Keys.notificationKey] as? Data,

                let alertDetailNotification = try? decoder.decode(SeptaAlertDetourNotification.self, from: data) else { return }

            findRouteAndDeepLink(notification: alertDetailNotification)

        default:
            break
        }
    }

    static func findRouteAndDeepLink(notification: SeptaAlertDetourNotification) {
        let transitMode = notification.transitMode
        RoutesCommand.sharedInstance.routes(forTransitMode: transitMode) { routes, _ in
            guard let route = routes?.first(where: { $0.routeId == notification.routeId }) else { return }

            let scheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: route)
            let scheduleState = ScheduleState(scheduleRequest: scheduleRequest, scheduleData: ScheduleData(), scheduleStopEdit: ScheduleStopEdit())
            let action = NavigateToAlertDetailsFromNotification(scheduleState: scheduleState)
            store.dispatch(action)
        }
    }
}
