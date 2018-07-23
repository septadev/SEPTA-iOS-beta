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

    let refreshTransitViewRoutes: Bool
    let refreshVehicleLocationData: Bool

    init(availableRoutes: [TransitRoute] = [], transitViewModel: TransitViewModel = TransitViewModel(), locations: [TransitViewVehicleLocation] = [], refreshRoutes: Bool = false, refreshVehicleLocations: Bool = false) {
        self.availableRoutes = availableRoutes
        self.transitViewModel = transitViewModel
        vehicleLocations = locations
        refreshTransitViewRoutes = refreshRoutes
        refreshVehicleLocationData = refreshVehicleLocations
    }
}

extension TransitViewState: Equatable {}
func == (lhs: TransitViewState, rhs: TransitViewState) -> Bool {
    return (lhs.availableRoutes == rhs.availableRoutes) &&
        (lhs.transitViewModel == rhs.transitViewModel) &&
        (lhs.vehicleLocations == rhs.vehicleLocations)
}
