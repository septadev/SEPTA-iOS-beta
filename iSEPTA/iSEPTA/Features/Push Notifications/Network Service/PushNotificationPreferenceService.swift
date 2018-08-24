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
            postBody = PushNotificationPreferencePostBody(deviceId: state.deviceId, regToken: state.firebaseToken, specialAnnouncements: false, timeWindows: nil, routeSubscriptions: nil)
        }

        print(":M: making api call to save push notif pref")
        print(":M: deviceId: \(postBody.deviceId)")
        print(":M: token: \(postBody.regToken)")
        print(":M: specials: \(postBody.specialAnnouncements)")
        print(":M: routes: \(postBody.routeSubscriptions ?? [])")
        print(":M: windows: \(postBody.timeWindows ?? [])")

        store.dispatch(PushNotificationPreferenceSynchronizationSuccess())

        // If success
        //   dispatch PushNotificationPreferenceSynchronizationSuccess()
        //     this will set syncStatus to .upToDate
        // Else
        //   dispatch PushNotificationPreferenceSynchronizationFail()
        //     this will copy the lastSync'd property to pushPrefState and set syncStatus to .upToDate
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
