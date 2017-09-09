//
//  NextToArriveScheduleRequestWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class NextToArriveScheduleRequestWatcher: StoreSubscriber {

    typealias StoreSubscriberStateType = ScheduleRequest
    init() {
        subscribe()
    }

    deinit {
        unsubscribe()
    }

    var currentScheduleRequest = ScheduleRequest()

    func newState(state: ScheduleRequest) {

        if let selectedRoute = state.selectedRoute, let selectedStart = state.selectedStart, let selectedEnd = state.selectedEnd {
            guard selectedRoute != currentScheduleRequest.selectedRoute,
                selectedStart != currentScheduleRequest.selectedStart,
                selectedEnd != currentScheduleRequest.selectedEnd else { return }
            let action = NextToArrivePrerequisitesStatus(status: true)
            store.dispatch(action)
        } else {
            let action = NextToArrivePrerequisitesStatus(status: false)
            store.dispatch(action)
        }
        currentScheduleRequest = state
    }
}

extension NextToArriveScheduleRequestWatcher: SubscriberUnsubscriber {

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.scheduleState.scheduleRequest
            }.skipRepeats { $0 == $1 }
        }
    }
}
