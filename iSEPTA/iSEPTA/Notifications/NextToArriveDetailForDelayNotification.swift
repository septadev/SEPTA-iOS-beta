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

    var timer: Timer?
    var tripId: Int = 0
    var routeId: String = ""

    private init() {}

    func waitForRealTimeData(routeId _: String, tripId: String) {
        guard let tripIdInt = Int(tripId) else { return }
        self.tripId = tripIdInt
        startTimer()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.nextToArriveTrips }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(tenSecondTimerFired(timer:)), userInfo: nil, repeats: true)
    }

    func newState(state: StoreSubscriberStateType) {
        let trips: [NextToArriveStop] = state.map({ $0.startStop }) + state.map({ $0.endStop })
        if let matchingStop = trips.first(where: { $0.tripId == self.tripId && $0.routeId == self.routeId }) {
            let action = ShowTripDetails(nextToArriveStop: matchingStop)
            store.dispatch(action)
        }
    }

    @objc func tenSecondTimerFired(timer _: Timer) {
        store.unsubscribe(self)
    }
}
