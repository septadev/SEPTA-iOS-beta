//
//  NotificationActions.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

protocol NotificationAction: SeptaAction {}

struct DelayNotificationTapped: NotificationAction {
    let payload: SeptaNotification
    let description: String
}
