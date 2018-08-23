//
//  PushNotificationPreferenceService.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct PushNotificationPreferenceService {
    static func post(state: PushNotificationPreferenceState) {
        var postBody: PushNotificationPreferencePostBody
        if state.userWantsToEnablePushNotifications {
            postBody = convertStateToPostBody(state: state)
        } else {
            postBody = PushNotificationPreferencePostBody(deviceId: state.deviceId, regToken: "", specialAnnouncements: false, timeWindows: nil, routeSubscriptions: nil)
        }

        print("Save notification preference to api: \(postBody)")
    }

    private static func convertStateToPostBody(state: PushNotificationPreferenceState) -> PushNotificationPreferencePostBody {
        let days = state.daysOfWeek.selectedDays()
        var timeWindows: [TimeWindow] = []
        for window in state.notificationTimeWindows {
            guard let startDate = window.startMinute.timeOnlyDate, let endDate = window.endMinute.timeOnlyDate else { break }
            let startTime = TimeWindow.convertDateToTimeString(date: startDate)
            let endTime = TimeWindow.convertDateToTimeString(date: endDate)
            timeWindows.append(TimeWindow(startTime: startTime, endTime: endTime, subscribedDays: days))
        }

        var routes: [RouteSubscription] = []
        for route in state.routeIds {
            if route.isEnabled {
                routes.append(RouteSubscription(routeId: route.routeId, alerts: true, detour: true, delays: true))
            }
        }

        return PushNotificationPreferencePostBody(
            deviceId: state.deviceId,
            regToken: state.firebaseToken,
            specialAnnouncements: state.userWantsToReceiveSpecialAnnoucements,
            timeWindows: timeWindows,
            routeSubscriptions: routes)
    }
}
