//
//  ScheduleTransitModesToolBarViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class ScheduleTransitModesToolBarViewController: BaseTransitModesToolbarViewController {

    override func awakeFromNib() {
        targetForScheduleAction = TargetForScheduleAction.schedules
        super.awakeFromNib()
    }

    override func subscribe() {

        store.subscribe(self) { subscription in
            subscription.select {
                $0.scheduleState.scheduleRequest.transitMode
            }.skipRepeats { $0 == $1 }
        }
    }
}
