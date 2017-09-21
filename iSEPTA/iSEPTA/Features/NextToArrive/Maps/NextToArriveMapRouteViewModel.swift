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
        return store.state.nextToArriveState.scheduleState.scheduleRequest.selectedRoute?.routeId
    }

    func subscribe() {
        guard let target = store.state.targetForScheduleActions() else { return }

        switch target {
        case .nextToArrive:
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.nextToArriveTrips
                }.skipRepeats { $0 == $1 }
            }
        case .favorites:
            store.subscribe(self) {
                $0.select {
                    $0.favoritesState.nextToArriveTrips
                }.skipRepeats { $0 == $1 }
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
            let startVehicles: [CLLocationCoordinate2D?] = trips.map { $0.vehicleLocation.firstLegLocation }
            let endVehicles: [CLLocationCoordinate2D?] = trips.map { $0.vehicleLocation.secondLegLocation }
            let allVehicles = startVehicles + endVehicles
            let nonOptionalVehicles: [CLLocationCoordinate2D] = allVehicles.flatMap { $0 }

            let allRouteIds = NextToArriveGrouper.filterRoutesToMap(trips: trips, requestRouteId: requestedRoutedId)

            delegate.drawRoutes(routeIds: allRouteIds)
            delegate.drawVehicleLocations(nonOptionalVehicles)
        }
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
