//
//  AppAlert.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/16/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum AppAlert: Equatable {
    case genericAlert                       //
    case databaseUpdateNeededAlert          // MainNavigationController.swift
    case databaseUpdateCompletedAlert       // MainNavigationController.swift
    case pushNotificationTripDetailAlert    // MainNavigationController.swift
    case pushNotificationExpiredAlert       // MainNavigationController.swift
    case databaseAlert                      // TripScheduleViewController.swift
}
