//
//  ScheduleProviderDatabaseStateWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleProviderDatabaseStateWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseState

    weak var delegate: BaseScheduleDataProvider?

    init() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.databaseState }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state == .loaded {
            delegate?.subscribe()
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
