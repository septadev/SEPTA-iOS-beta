//
//  PushNotificationPreferenceService.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

struct PushNotificationPreferenceService {
    static func post(state: PushNotificationPreferenceState, showSuccess: Bool) {
        guard state.firebaseToken != "" else {
            return
        }

        let body = postBody(state: state)

        guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "septaBaseUrl") as? String,
            let url = URL(string: "\(baseUrl)/pushnotification/subscription"),
            let httpBody = try? JSONEncoder().encode(body),
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "septaApiKey") as? String else {
            store.dispatch(PushNotificationPreferenceSynchronizationFail())
            return
        }

        let request = buildRequest(url: url, key: apiKey, body: httpBody)
        let session = URLSession.shared

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        // TODO: JJ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            session.dataTask(with: request) { _, _, error in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                if error != nil {
                    DispatchQueue.main.async {
                        showAlert(title: "There was an error saving push notification preferences.")
                    }
                } else {
                    DispatchQueue.main.async {
                        if showSuccess {
                            showAlert(title: "Push notification preferences saved.")
                        }
                        PushNotificationKeepAlive.preferencesSaved()
                        store.dispatch(PushNotificationPreferenceSynchronizationSuccess())
                    }
                }
            }.resume()
        }
    }

    private static func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.show()
    }

    private static func buildRequest(url: URL, key: String, body: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.httpBody = body
        return request
    }

    private static func postBody(state: PushNotificationPreferenceState) -> PushNotificationPreferencePostBody {
        if state.userWantsToEnablePushNotifications {
            return convertStateToPostBody(state: state)
        } else {
            return PushNotificationPreferencePostBody(deviceId: state.deviceId, regToken: state.firebaseToken, specialAnnouncements: false, timeWindows: nil, routeSubscriptions: nil)
        }
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
