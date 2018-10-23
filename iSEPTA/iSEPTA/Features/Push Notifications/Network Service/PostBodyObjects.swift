//
//  PostBodyObjects.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct PushNotificationPreferencePostBody: Codable {
    let deviceId: String
    let regToken: String
    let specialAnnouncements: Bool
    let timeWindows: [TimeWindow]?
    let routeSubscriptions: [RouteSubscription]?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case regToken = "reg_token"
        case specialAnnouncements = "special_announcements"
        case timeWindows = "time_windows"
        case routeSubscriptions = "route_subscriptions"
    }
}

struct TimeWindow: Codable {
    let startTime: String
    let endTime: String
    let subscribedDays: [Int]

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case subscribedDays = "subscribed_days"
    }

    static func convertDateToTimeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct RouteSubscription: Codable {
    let routeId: String
    let alerts: Bool
    let detour: Bool
    let delays: Bool

    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
        case alerts
        case detour
        case delays
    }
}
