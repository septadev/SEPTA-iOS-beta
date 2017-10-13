//
//  TripDetailStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

class TripDetailStateProvider: TripDetailState_TripDetailsExistWatcherDelegate {
    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    let watcher = TripDetailState_TripDetailsExistWatcher()

    static let sharedInstance: TripDetailStateProvider = TripDetailStateProvider()
    var timer: Timer?

    init() {
        watcher.delegate = self
    }

    func tripDetailState_TripDetailsExistUpdated(bool exists: Bool) {
        if exists {
            timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
        }
    }

    @objc func timerFired(timer _: Timer) {
        guard let nextToArriveStop = store.state.tripDetailState.tripDetails else { return }
        if nextToArriveStop.transitMode.useBusForDetails() {
            retrieveRealtimeDataForBusStop(nextToArriveStop)
        } else if nextToArriveStop.transitMode.useRailForDetails() {
            retrieveRealtimeDataForRailStop(nextToArriveStop)
        }
    }

    func retrieveRealtimeDataForRailStop(_ stop: NextToArriveStop) {
        guard let tripIdInt = stop.tripId, stop.hasRealTimeData else { return }

        client.getRealTimeRailArrivalDetail(tripId: String(tripIdInt)).then { details -> Void in
            guard let details = details else { return }
            self.dispatchAction(stop: stop, details: details)
        }.catch { error in
            print(error.localizedDescription)
        }
    }

    func retrieveRealtimeDataForBusStop(_ stop: NextToArriveStop) {
        guard let vehicleIds = stop.vehicleIds, let vehicleId = vehicleIds.first else { return }

        client.getRealTimeBusArrivalDetail(vehicleId: vehicleId, routeId: stop.routeId).then { details -> Void in
            guard let details = details else { return }
            self.dispatchAction(stop: stop, details: details)
        }.catch { error in
            print(error.localizedDescription)
        }
    }

    func dispatchAction(stop: NextToArriveStop, details: RealTimeArrivalDetail) {
        var newStop = stop
        newStop.addRealTimeData(nextToArriveDetail: details)
        let action = UpdateTripDetails(tripDetails: newStop)
        store.dispatch(action)
    }
}
