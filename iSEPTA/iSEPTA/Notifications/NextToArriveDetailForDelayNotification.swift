//
//  NextToArriveDetailForDelayNotification.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class NextToArriveDetailForDelayNotification: StoreSubscriber {
    typealias StoreSubscriberStateType = [NextToArriveTrip]
    public static let sharedInstance = NextToArriveDetailForDelayNotification()

    var tripIdInt: Int = 0

    var timer: Timer?

    private init() {}

    func waitForRealTimeData(tripId: String) {
        guard let tripIdInt = Int(tripId) else { return }
        self.tripIdInt = tripIdInt
        subscribe()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
            timer.invalidate()
            store.unsubscribe(self)
        })
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.nextToArriveTrips }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        let trips = state

        let allstops = trips.map({ $0.startStop }) + trips.map({ $0.endStop })

        let matchingStop = allstops.first(where: {
            guard let tripIdInt = $0.tripId else { return false }
            return tripIdInt == self.tripIdInt
        })

        if let matchingStop = matchingStop, matchingStop.nextToArriveDetail != nil {
            let action = UpdateTripDetails(tripDetails: matchingStop)
            store.dispatch(action)
            let resetViewState = ResetViewState(viewController: .tripDetailViewController, description: "loading up trip detail")
            store.dispatch(resetViewState)

            store.unsubscribe(self)
        }
    }
}
