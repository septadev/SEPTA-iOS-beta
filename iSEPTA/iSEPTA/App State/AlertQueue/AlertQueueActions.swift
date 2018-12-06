//
//  AlertQueueActions.swift
//  iSEPTA
//
//  Created by James Johnson on 12/06/2018.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol AlertQueueAction: SeptaAction {}

struct AddAlertToDisplay: AlertQueueAction, Equatable {
    let appAlert: AppAlert
    let description = "Adding a global Alert to Display"
}

struct CurrentAlertDismissed: AlertQueueAction, Equatable {
    let description = "Just Dismissed an App Alert"
}
