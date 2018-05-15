//
//  NextToArriveEndpointsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import CoreLocation

class NextToArriveMapEndpointsViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: RouteDrawable! {
        didSet {
            subscribe()
        }
    }

    func subscribe() {

        guard let target = store.state.targetForScheduleActions() else { return }

        switch target {
        case .nextToArrive:
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleRequest
                }
            }
        case .favorites:
            store.subscribe(self) {
                $0.select {
                    $0.favoritesState.nextToArriveScheduleRequest
                }
            }
        default:
            break
        }
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    func newState(state: StoreSubscriberStateType) {
        guard let delegate = delegate else { return }

        delegate.drawTrip(scheduleRequest: state)
    }
}
