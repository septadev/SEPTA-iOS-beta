//
//  NextToArriveScheduleRequestWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

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
        let scheduleRequest = state
        let newStatus = prerequisitesExistForNTA(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForNTAHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsChanged {
            let updatePreReqsAction = NextToArrivePrerequisteStatusChanged(newStatus: newStatus)
            store.dispatch(updatePreReqsAction)

            if newStatus == .prerequisitesExist {
                let clearTripsAction = ClearNextToArriveData()
                store.dispatch(clearTripsAction)

                let updateRequestedAction = NextToArriveRefreshDataRequested(refreshUpdateRequested: true)
                store.dispatch(updateRequestedAction)
            }
        }

        currentScheduleRequest = state
    }

    func prerequisitesExistForNTA(scheduleRequest: ScheduleRequest) -> NextToArrivePrerequisiteStatus {
        if scheduleRequest.selectedRoute != nil &&
            scheduleRequest.selectedStart != nil &&
            scheduleRequest.selectedEnd != nil {
            return .prerequisitesExist
        } else {
            return .missingPrerequisites
        }
    }

    func prerequisitesForNTAHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let selectedRouteComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)
        let selectedStartComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)
        let scheduleEndComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)
        return !selectedRouteComparison.equalityResult() || !selectedStartComparison.equalityResult() || !scheduleEndComparison.equalityResult()
    }

    func nextToArrivePrerequisiteStatusHasChanged(newStatus: NextToArrivePrerequisiteStatus) -> Bool {
        let currentNextToArrivePrerequisiteStatus = store.state.nextToArriveState.nextToArrivePrerequisiteStatus
        return currentNextToArrivePrerequisiteStatus != newStatus
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
