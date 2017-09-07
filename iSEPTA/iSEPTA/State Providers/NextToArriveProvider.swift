//
//  NextToArriveProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule
import ReSwift

class NextToArriveProvider: StoreSubscriber {

    typealias StoreSubscriberStateType = Bool

    static let sharedInstance = NextToArriveProvider()

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    private init() {

        subscribe()
    }

    deinit {
        unsubscribe()
    }

    func newState(state: Bool) {
        let updateRequested = state
        if updateRequested {
            let scheduleRequest = store.state.nextToArriveState.scheduleState.scheduleRequest
            retrieveNextToArrive(scheduleRequest: scheduleRequest, completion: nil)
        }
    }

    func retrieveNextToArrive(scheduleRequest: ScheduleRequest, completion: (([RealTimeArrival]) -> Void)?) {
        guard
            let startId = scheduleRequest.selectedStart?.stopId,
            let stopId = scheduleRequest.selectedEnd?.stopId,
            let route = scheduleRequest.selectedRoute?.routeId else { return }
        let transitType = TransitType.fromTransitMode(scheduleRequest.transitMode)
        let originId = String(startId)
        let destinationId = String(stopId)
        client.getRealTimeArrivals(originId: originId, destinationId: destinationId, transitType: transitType, route: route).then { realTimeArrivals -> Void in
            guard let arrivals = realTimeArrivals?.arrivals else { return }
            completion?(arrivals)
        }.catch { err in
            print(err)
        }
    }
}

extension NextToArriveProvider: SubscriberUnsubscriber {
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.updateRequested
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
