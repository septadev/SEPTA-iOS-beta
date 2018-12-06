//
//  AppAlertEnum.swift
//  iSEPTA
//
//  Created by James Johnson on 12/06/2018.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum AppAlert: Equatable {
    case appAlert
    case appAndGenericAlert
    case databaseAlert
    case databaseUpdateNeededAlert
    //case databaseUpdateNeededWarmAlert
    case databaseUpdateCompletedAlert
    case empty
    case genericAlert
    case pushNotificationTripDetailAlert
    case pushNotificationExpiredAlert
}
