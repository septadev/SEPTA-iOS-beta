//
//  NotificationProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import CoreLocation
import ReSwift
import SeptaRest
import SeptaSchedule

class NotificationProvider: StoreSubscriber {
    static let sharedInstance = NotificationProvider()

    typealias StoreSubscriberStateType = SeptaNotification?

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    init() {
        subscribe()
    }

    func subscribe() {
//        store.subscribe(self) {
//            $0.select { $0.notificationState.payload }.skipRepeats { $0 == $1 }
//        }
    }

    func newState(state _: StoreSubscriberStateType) {
//        if let vehicleId = state?.vehicleId, let routeId = state?.routeId {
//            retrieveRealTimeRailDetail(vehicleId: vehicleId, routeId: routeId)
//        }
    }

    func retrieveRealTimeRailDetail(vehicleId: String, routeId: String) {
        client.getRealTimeRailArrivalDetail(tripId: vehicleId).then { details -> Void in
            guard let details = details else { return }

            let ntaStop = self.convertRailDetailsToStop(details: details, routeId: routeId)
            let action = UpdateTripDetails(tripDetails: ntaStop)
            store.dispatch(action)
        }.catch { error in
            print(error.localizedDescription)
        }
    }

    private func convertRailDetailsToStop(details: NextToArriveRailDetails, routeId: String) -> NextToArriveStop {
        var vehicleLocation: CLLocationCoordinate2D?
        if let lat = details.latitude, let lon = details.longitude {
            vehicleLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        var direction: RouteDirectionCode?
        if let dir = details.direction {
            direction = RouteDirectionCode.fromNetwork(dir)
        }

        return NextToArriveStop(transitMode: .rail, routeId: routeId, routeName: details.line ?? "", tripId: details.tripid, arrivalTime: Date(), departureTime: Date(), lastStopId: nil, lastStopName: details.destination, delayMinutes: details.destinationDelay, direction: direction, vehicleLocationCoordinate: vehicleLocation, vehicleIds: details.consist, hasRealTimeData: false, service: details.service)
    }
}
