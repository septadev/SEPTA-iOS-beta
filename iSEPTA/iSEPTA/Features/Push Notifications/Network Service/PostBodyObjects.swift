//
//  PostBodyObjects.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct PushNotificationPreferencePostBody {
    let deviceId: String
    let regToken: String
    let specialAnnouncements: Bool
    let timeWindows: [TimeWindow]?
    let routeSubscriptions: [RouteSubscription]?
}

struct TimeWindow {
    let startTime: String
    let endTime: String
    let subscribedDays: [String]

    static func convertDateToTimeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct RouteSubscription {
    let routeId: String
    let alerts: Bool
    let detour: Bool
    let delays: Bool
}

/*
 {
 "device_id": "479d38f4-6e74-4a42-b1f7-40b81bea9999",
 "reg_token": "mike6JwEK84:APA91bGRQVe4co_11XJL_r4Q0kRl5fChS7K33DYUnMq5YBAby19AUGUi5GiTF_ku8mVTfw0e888Zy1ARy1Ge7mB0v7sRJjd7dA8JlqB-nPKxfS6kC9AmkWVGEyVH-lhHW386QsNw9paLyYvPsAFyafvHHCmcH3_hWQ",
 "special_announcements": true,
 "time_windows": [
 {
 "start_time": "06:00:00",
 "end_time": "17:00:00",
 "subscribed_days": [
 "1",
 "2",
 "3",
 "4",
 "5"
 ]
 }
 ],
 "route_subscriptions": [
 {
 "route_id": "PAO",
 "alerts": true,
 "detour": true,
 "delays": true
 }
 ]
 }
 */
