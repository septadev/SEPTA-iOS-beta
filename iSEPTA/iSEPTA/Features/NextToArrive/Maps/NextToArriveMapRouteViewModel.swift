//
//  NextToArriveMapRouteViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import CoreLocation

class NextToArriveMapRouteViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = [NextToArriveTrip]

    weak var delegate: RouteDrawable! {
        didSet {
            subscribe()
            nextToArriveMapRouteViewModelErrorWatcher.delegate = delegate
        }
    }

    let nextToArriveMapRouteViewModelErrorWatcher = NextToArriveMapRouteViewModelErrorWatcher()

    var requestedRoutedId: String? {
        guard let target = store.state.targetForScheduleActions() else { return nil }

        switch target {
        case .nextToArrive:
            return store.state.nextToArriveState.scheduleState.scheduleRequest.selectedRoute?.routeId
        case .favorites:
            return store.state.favoritesState.nextToArriveFavorite?.scheduleRequest.selectedRoute?.routeId
        default:
            return nil
        }
    }

    func subscribe() {
        guard let target = store.state.targetForScheduleActions() else { return }

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

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    var currentTrips = [NextToArriveTrip]()
    func newState(state: StoreSubscriberStateType) {
        let trips = state

        guard let target = store.state.targetForScheduleActions() else { return }
        let updateStatus: NextToArriveUpdateStatus
        switch target {
        case .nextToArrive:
            updateStatus = store.state.nextToArriveState.nextToArriveUpdateStatus
        case .favorites:
            updateStatus = store.state.favoritesState.nextToArriveUpdateStatus
        default:
            updateStatus = .idle
        }
        if updateStatus == .dataLoadedSuccessfully {

            handleVehicleLocations(trips: trips)
            currentTrips = trips
        }

        let allRouteIds = NextToArriveGrouper.filterRoutesToMap(trips: trips, requestRouteId: requestedRoutedId)

        delegate.drawRoutes(routeIds: allRouteIds)
    }

    func handleVehicleLocations(trips: [NextToArriveTrip]) {
        let connectionTrips = trips.filter {
            guard let startTripId = $0.startStop.tripId, let endTripId = $0.endStop.tripId else { return false }
            return startTripId != endTripId
        }
        let noConnectionTrips = trips.filter {
            guard let startTripId = $0.startStop.tripId, let endTripId = $0.endStop.tripId else { return false }
            return startTripId == endTripId
        }

        let tripLegs =
            connectionTrips.map { $0.startStop }
            + connectionTrips.map { $0.endStop }
            + noConnectionTrips.map { $0.startStop }

        let mappableVehicles: [VehicleLocation] = tripLegs
            .filter({ $0.vehicleLocationCoordinate != nil })
            .map { return VehicleLocation(location: $0.vehicleLocationCoordinate!, nextToArriveStop: $0) }

        delegate.drawVehicleLocations(mappableVehicles)
    }
}

class NextToArriveMapRouteViewModelErrorWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = NextToArriveUpdateStatus

    weak var delegate: RouteDrawable! {
        didSet {
            subscribe()
        }
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.nextToArriveUpdateStatus
            }
        }
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    func newState(state: StoreSubscriberStateType) {

        if state == .dataLoadingError {
            //            if let routeId = store.state.nextToArriveState.scheduleState.scheduleRequest.selectedRoute?.routeId {
            //
            //            }
        }
    }
}
