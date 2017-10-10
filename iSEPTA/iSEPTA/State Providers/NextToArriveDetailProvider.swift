//
//  NextToArriveDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import SeptaRest

class NextToArriveDetailProvider {
    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    func retrieveNextToArriveDetail(nextToArriveTrip: NextToArriveTrip, transitMode: TransitMode) {
        if nextToArriveTrip.startStop.hasRealTimeData && transitMode.useRailForDetails() {
            retrieveRealtimeDataForRailStop(nextToArriveTrip.startStop)
        } else if nextToArriveTrip.endStop.hasRealTimeData && transitMode.useRailForDetails() {
            retrieveRealtimeDataForRailStop(nextToArriveTrip.endStop)
        } else if nextToArriveTrip.startStop.hasRealTimeData && transitMode.useBusForDetails() {
            retrieveRealtimeDataForBusStop(nextToArriveTrip.startStop)
        }
    }

    func retrieveRealtimeDataForRailStop(_ stop: NextToArriveStop) {
        guard let tripIdInt = stop.tripId, stop.hasRealTimeData else { return }
        client.getRealTimeRailArrivalDetail(tripId: String(tripIdInt)).then { details -> Void in
            guard let details = details else { return }
            let action = UpdateNextToArriveDetail(realTimeArrivalDetail: details, description: "Loading Rail Details")
            store.dispatch(action)
        }.catch { error in
            print(error.localizedDescription)
        }
    }

    func retrieveRealtimeDataForBusStop(_ stop: NextToArriveStop) {
        guard let vehicleIds = stop.vehicleIds, let vehicleId = vehicleIds.first else { return }

        client.getRealTimeBusArrivalDetail(vehicleId: vehicleId, routeId: stop.routeId).then { details -> Void in
            guard let details = details else { return }
            let action = UpdateNextToArriveDetail(realTimeArrivalDetail: details, description: "Loading Bus Details")
            store.dispatch(action)
        }.catch { error in
            print(error.localizedDescription)
        }
    }
}
