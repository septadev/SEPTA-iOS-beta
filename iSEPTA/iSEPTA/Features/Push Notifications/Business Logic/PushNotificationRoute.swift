//
//  PushNotificationRoute.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct PushNotificationRoute: Codable, Equatable {
    let routeId: String
    let routeName: String
    let transitMode: TransitMode
    let isEnabled: Bool

    init(routeId: String, routeName: String, transitMode: TransitMode, isEnabled: Bool = true) {
        self.routeId = routeId
        self.transitMode = transitMode
        self.isEnabled = isEnabled
        self.routeName = routeName
    }
}

extension Array where Iterator.Element == PushNotificationRoute {
    func indexOfRoute(route: PushNotificationRoute) -> Int? {
        return index(where: { $0.routeId == route.routeId && $0.transitMode == route.transitMode })
    }
}
