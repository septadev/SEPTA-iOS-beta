//
//  AlertState_ScheduleState_ScheduleRequestWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import SeptaSchedule
import ReSwift

protocol AlertState_ScheduleState_ScheduleRequestWatcherDelegate: AnyObject {
    func alertState_ScheduleState_ScheduleRequestUpdated(scheduleRequest: ScheduleRequest)
}

class AlertState_ScheduleState_ScheduleRequestWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: AlertState_ScheduleState_ScheduleRequestWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.scheduleState.scheduleRequest }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_ScheduleState_ScheduleRequestUpdated(scheduleRequest: state)
    }
}
