//
//  NextToArriveInfoViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class NextToArriveInfoViewModel: BaseNextToArriveInfoViewModel, StoreSubscriber, SubscriberUnsubscriber {
    typealias StoreSubscriberStateType = [NextToArriveTrip]

    override func scheduleRequest() -> ScheduleRequest {
        return store.state.currentTargetForScheduleActionsScheduleRequest()
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
        guard let target = store.state.currentTargetForScheduleActions() else { return }

        switch target {
        case .nextToArrive:
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.nextToArriveTrips
                }.skipRepeats({ (_, _) -> Bool in
                    false
                })
            }
        case .favorites:
            store.subscribe(self) {
                $0.select {
                    $0.favoritesState.nextToArriveTrips
                }.skipRepeats({ (_, _) -> Bool in
                    false
                })
            }
        default:
            break
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
