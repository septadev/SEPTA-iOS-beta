//
//  BaseScheduleRequestWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class BaseScheduleRequestWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: ScheduleRequestWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        // handled by subclasses
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.scheduleRequestUpdated(scheduleRequest: state)
    }
}
