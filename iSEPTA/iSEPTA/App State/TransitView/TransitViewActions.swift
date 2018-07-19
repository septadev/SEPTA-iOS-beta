//
//  TransitViewActions.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

protocol TransitViewAction: SeptaAction {}

struct TransitViewRoutesLoaded: TransitViewAction {
    let routes: [TransitRoute]
    let description: String
}

struct TransitViewRouteSelected: TransitViewAction {
    let slot: TransitViewRouteSlot
    let route: TransitRoute
    let description: String
}

struct ResetTransitView: TransitViewAction {
    let description: String
}

struct TransitViewSlotChange: TransitViewAction {
    let slot: TransitViewRouteSlot
    let description: String
}

struct RefreshTransitViewVehicleLocationData: TransitViewAction {
    let description: String
}

struct TransitViewRouteLocationsDownloaded: TransitViewAction {
    let locations: [TransitViewVehicleLocation]
    let description: String
}

struct TransitViewRemoveRoute: TransitViewAction {
    let route: TransitRoute
    let description: String
}
