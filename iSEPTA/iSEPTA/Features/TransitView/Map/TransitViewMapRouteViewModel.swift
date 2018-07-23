//
//  TransitViewMapRouteViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/11/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit
import ReSwift
import SeptaSchedule

class TransitViewMapRouteViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = [TransitViewVehicleLocation]

    var delegate: TransitViewMapDataProviderDelegate? {
        didSet {
            subscribe()
        }
    }

    private func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.transitViewState.vehicleLocations
            }.skipRepeats {
                $0 == $1
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        let routes = state.map { $0.routeId }
        let uniqueRoutes = Array(Set(routes))
        delegate?.drawRoutes(routeIds: uniqueRoutes)
        delegate?.drawVehicleLocations(locations: state)
    }

    deinit {
        store.unsubscribe(self)
    }
}

protocol TransitViewMapDataProviderDelegate {
    func drawRoutes(routeIds: [String])
    func drawVehicleLocations(locations: [TransitViewVehicleLocation])
}
