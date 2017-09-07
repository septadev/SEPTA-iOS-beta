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
import CoreLocation

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
            retrieveNextToArrive(scheduleRequest: scheduleRequest, completion: mapArrivals)
        }
    }

    func mapArrivals(realTimeArrivals: [RealTimeArrival]) {
        var trips = [NextToArriveTrip]()
        for realTimeArrival in realTimeArrivals {
            let startStop = mapStart(realTimeArrival: realTimeArrival)
            let endStop = mapEnd(realTimeArrival: realTimeArrival)
            let vehicleLocation = mapVehicleLocation(realTimeArrival: realTimeArrival)
            let connectionLocation = mapConnectionStation(realTimeArrival: realTimeArrival)

            if let startStop = startStop, let endStop = endStop {
                let nextToArriveTrip = NextToArriveTrip(startStop: startStop, endStop: endStop, vehicleLocation: vehicleLocation, connectionLocation: connectionLocation)
                trips.append(nextToArriveTrip)
            }
        }
    }

    func mapStart(realTimeArrival a: RealTimeArrival) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard let arrivalTimeString = a.orig_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            let departureTimeString = a.orig_departure_time,

            let departureTime = formatter.date(from: departureTimeString) else {
            return nil
        }
        return NextToArriveStop(routeId: a.orig_line_route_id,
                                routeName: a.orig_line_route_name,
                                tripId: Int(a.orig_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.orig_last_stop_id ?? ""),
                                lastStopName: a.orig_last_stop_name,
                                delayMinutes: a.orig_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.orig_line_direction ?? ""))
    }

    func mapEnd(realTimeArrival a: RealTimeArrival) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard let arrivalTimeString = a.term_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            let departureTimeString = a.term_departure_time,
            let departureTime = formatter.date(from: departureTimeString) else {
            return nil
        }
        return NextToArriveStop(routeId: a.term_line_route_id,
                                routeName: a.term_line_route_name,
                                tripId: Int(a.term_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.term_last_stop_id ?? ""),
                                lastStopName: a.term_last_stop_name,
                                delayMinutes: a.term_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.term_line_direction ?? ""))
    }

    func mapVehicleLocation(realTimeArrival a: RealTimeArrival) -> VehicleLocation? {
        var firstLegLocation = CLLocationCoordinate2D()
        if let location = mapCoordinateFromString(latString: a.vehicle_lat, lonString: a.vehicle_lon) {
            firstLegLocation = location
        } else if let location = mapCoordinateFromString(latString: a.orig_vehicle_lat, lonString: a.orig_vehicle_lon) {
            firstLegLocation = location
        }
        let secondLegLocation = mapCoordinateFromString(latString: a.term_vehicle_lat, lonString: a.term_vehicle_lon) ?? CLLocationCoordinate2D()

        return VehicleLocation(firstLegLocation: firstLegLocation, secondLegLocation: secondLegLocation)
    }

    func mapConnectionStation(realTimeArrival a: RealTimeArrival) -> NextToArriveConnectionStation? {
        guard let stopName = a.connection_station_name else { return nil }
        var stopId: Int?
        if let stopIdString = a.connection_station_id, let stopIdInt = Int(stopIdString) {
            stopId = stopIdInt
        }
        return NextToArriveConnectionStation(stopId: stopId, stopName: stopName)
    }

    func mapCoordinateFromString(latString: String?, lonString: String?) -> CLLocationCoordinate2D? {
        guard
            let latString = latString,
            let latDegrees = CLLocationDegrees(latString),
            let lonString = lonString,
            let lonDegrees = CLLocationDegrees(lonString) else { return nil }

        return CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
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
