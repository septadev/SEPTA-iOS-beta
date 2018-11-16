//
//  AppAlert.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/16/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum AppAlert: Equatable {
    case genericAlert
    case globalSystemAlert
    case databaseUpdateNeededAlert
    case databaseUpdateCompletedAlert
    case pushNotificationTripDetailAlert
    case pushNotificationExpiredAlert
    case databaseAlert
}
