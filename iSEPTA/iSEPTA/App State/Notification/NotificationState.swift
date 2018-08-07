//
//  NotificationState.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct NotificationState: Codable, Equatable {
    var payload: SeptaNotification?

    init(payload: SeptaNotification? = nil) {
        self.payload = payload
    }
}
