//
//  ScheduleRequestWatcherDelegate.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
protocol ScheduleRequestWatcherDelegate: AnyObject {
    func scheduleRequestUpdated(scheduleRequest: ScheduleRequest)
}
