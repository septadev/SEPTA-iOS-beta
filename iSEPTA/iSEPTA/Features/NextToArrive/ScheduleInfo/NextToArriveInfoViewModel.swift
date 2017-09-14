//
//  NextToArriveInfoViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

class NextToArriveInfoViewModel: BaseNextToArriveInfoViewModel, StoreSubscriber, SubscriberUnsubscriber {

    typealias StoreSubscriberStateType = [NextToArriveTrip]

    override func scheduleRequest() -> ScheduleRequest {
        return store.state.nextToArriveState.scheduleState.scheduleRequest
    }

    override func transitMode() -> TransitMode {
        return scheduleRequest().transitMode
    }

    func newState(state: StoreSubscriberStateType) {
        groupedTripData = NextToArriveGrouper.buildNextToArriveTripSections(trips: state)

        delegate.viewModelUpdated()
    }

    func viewTitle() -> String {
        return scheduleRequest().transitMode.nextToArriveInfoDetailTitle()
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.nextToArriveTrips
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
