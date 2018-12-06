//
//  AlertQueueState.swift
//  iSEPTA
//
//  Created by James Johnson on 12/06/2018.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

struct AlertQueueState: Equatable {
    var alertsToDisplay: [AppAlert] = [AppAlert]()
    var nextAlertToDisplay: AppAlert { return alertsToDisplay.first ?? .empty }
}
