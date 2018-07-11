//
//  TargetForScheduleActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum TargetForScheduleAction: Equatable {
    case schedules
    case nextToArrive
    case alerts
    case favorites
    case all

    func includesMe(_ targetForScheduleAction: TargetForScheduleAction) -> Bool {
        return self == .all || self == targetForScheduleAction
    }
}
