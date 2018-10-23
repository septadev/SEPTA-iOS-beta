//
//  TransitViewState.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule

struct TransitViewState {
    let availableRoutes: [TransitRoute]
    let transitViewModel: TransitViewModel
    let vehicleLocations: [TransitViewVehicleLocation]
    let routeSlotBeingChanged: TransitViewRouteSlot

    let refreshTransitViewRoutes: Bool
    let refreshVehicleLocationData: Bool

    init(availableRoutes: [TransitRoute] = [], transitViewModel: TransitViewModel = TransitViewModel(), locations: [TransitViewVehicleLocation] = [], routeSlotBeingChanged: TransitViewRouteSlot, refreshRoutes: Bool = false, refreshVehicleLocations: Bool = false) {
        self.availableRoutes = availableRoutes
        self.transitViewModel = transitViewModel
        vehicleLocations = locations
        self.routeSlotBeingChanged = routeSlotBeingChanged
        refreshTransitViewRoutes = refreshRoutes
        refreshVehicleLocationData = refreshVehicleLocations
    }
}

enum TransitViewRouteSlot: Int {
    case first = 1
    case second = 2
    case third = 3
}

extension TransitViewState: Equatable {}
func == (lhs: TransitViewState, rhs: TransitViewState) -> Bool {
    return (lhs.availableRoutes == rhs.availableRoutes) &&
        (lhs.transitViewModel == rhs.transitViewModel) &&
        (lhs.vehicleLocations == rhs.vehicleLocations) &&
        (lhs.routeSlotBeingChanged == rhs.routeSlotBeingChanged) &&
        (lhs.refreshTransitViewRoutes == rhs.refreshTransitViewRoutes) &&
        (lhs.refreshVehicleLocationData == rhs.refreshVehicleLocationData)
}
