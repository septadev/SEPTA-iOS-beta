//
//  ScheduleActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol ScheduleAction: Action {}

class ScheduleActions {
    struct WillViewSchedules: ScheduleAction {
    }

    struct TransitModeSelected: ScheduleAction {

        let transitMode: TransitMode
    }

    struct TransitModeDisplayed: ScheduleAction {
        let transitMode: TransitMode?
    }
}
