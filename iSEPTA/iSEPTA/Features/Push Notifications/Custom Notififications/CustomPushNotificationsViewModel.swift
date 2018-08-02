//
//  CustomPushNotificationsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

class CustomPushNotificationsViewModel {
    var routes = [PushNotificationRoute]()

    func numberOfRows() -> Int {
        return routes.count
    }

    func configureCellAtRow(cell: PushNotificationTableViewCell, row: Int) {
        guard row < routes.count else { return }
        let route = routes[row]

        cell.pushNotificationRoute = route
    }
}
