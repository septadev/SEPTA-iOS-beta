//
//  ScheduleActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class ScheduleActions {
    struct TransitModeSelected: Action {

        let transitMode: TransitMode?
    }

    struct TransitModeDisplayed {
        let transitMode: TransitMode?
    }
}
