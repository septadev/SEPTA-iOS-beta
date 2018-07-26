//
//  TransitViewReducer.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

struct TransitViewReducer {
    static func main(action: Action, state: TransitViewState?) -> TransitViewState {
        if let state = state {
            return reduceTransitViewState(action: action, state: state)
        } else {
            return TransitViewState(availableRoutes: [], transitViewModel: TransitViewModel(), locations: [], refreshRoutes: true, refreshVehicleLocations: false)
        }
    }

    private static func reduceTransitViewState(action: Action, state: TransitViewState) -> TransitViewState {
        guard let action = action as? TransitViewAction else { return state }

        if let action = action as? TransitViewRoutesLoaded {
            return TransitViewState(availableRoutes: action.routes, transitViewModel: state.transitViewModel)
        }

        if let action = action as? TransitViewRouteSelected {
            return reduceTransitViewRouteSelected(action: action, state: state)
        }

        if action is ResetTransitView {
            return TransitViewState(availableRoutes: state.availableRoutes)
        }

        if let action = action as? TransitViewSlotChange {
            let model = TransitViewModel(firstRoute: state.transitViewModel.firstRoute, secondRoute: state.transitViewModel.secondRoute, thirdRoute: state.transitViewModel.thirdRoute, slotBeingChanged: action.slot)
            return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model)
        }

        if action is RefreshTransitViewVehicleLocationData {
            return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: state.transitViewModel, locations: [], refreshRoutes: true, refreshVehicleLocations: true)
        }

        if let action = action as? TransitViewRouteLocationsDownloaded {
            return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: state.transitViewModel, locations: action.locations)
        }

        if let action = action as? TransitViewRemoveRoute {
            return reduceRemoveRouteAction(action: action, state: state)
        }

        if let action = action as? TransitViewFavoriteSelected {
            return reduceTransitViewFavoriteSelected(action: action, state: state)
        }

        return state
    }

    private static func reduceTransitViewRouteSelected(action: TransitViewRouteSelected, state: TransitViewState) -> TransitViewState {
        let first = action.slot == .first ? action.route : state.transitViewModel.firstRoute
        let second = action.slot == .second ? action.route : state.transitViewModel.secondRoute
        let third = action.slot == .third ? action.route : state.transitViewModel.thirdRoute
        let model = TransitViewModel(firstRoute: first, secondRoute: second, thirdRoute: third, slotBeingChanged: state.transitViewModel.slotBeingChanged)
        return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model)
    }

    private static func reduceRemoveRouteAction(action: TransitViewRemoveRoute, state: TransitViewState) -> TransitViewState {
        let deletedRoute = action.route

        var model = state.transitViewModel
        if let firstRoute = model.firstRoute, firstRoute == deletedRoute {
            model = deleteRouteFromModel(slot: .first, model: model)
        }
        if let secondRoute = model.secondRoute, secondRoute == deletedRoute {
            model = deleteRouteFromModel(slot: .second, model: model)
        }
        if let thirdRoute = model.thirdRoute, thirdRoute == deletedRoute {
            model = deleteRouteFromModel(slot: .third, model: model)
        }

        return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model, locations: state.vehicleLocations, refreshRoutes: state.refreshTransitViewRoutes, refreshVehicleLocations: state.refreshVehicleLocationData)
    }

    private static func deleteRouteFromModel(slot: TransitViewRouteSlot, model: TransitViewModel) -> TransitViewModel {
        switch slot {
        case .first:
            // Shift second and third route forward (if they exist) to prevent a gap
            let newFirst = model.secondRoute
            let newSecond = model.thirdRoute
            return TransitViewModel(firstRoute: newFirst, secondRoute: newSecond, thirdRoute: nil, slotBeingChanged: nil)
        case .second:
            // Shift third route forward (if it exists) to prevent a gap
            let newSecond = model.thirdRoute
            return TransitViewModel(firstRoute: model.firstRoute, secondRoute: newSecond, thirdRoute: nil, slotBeingChanged: nil)
        case .third:
            return TransitViewModel(firstRoute: model.firstRoute, secondRoute: model.secondRoute, thirdRoute: nil, slotBeingChanged: nil)
        }
    }

    private static func reduceTransitViewFavoriteSelected(action: TransitViewFavoriteSelected, state: TransitViewState) -> TransitViewState {
        let routes = action.favorite.transitViewRoutes
        var r1: TransitRoute?
        var r2: TransitRoute?
        var r3: TransitRoute?
        for (index, element) in routes.enumerated() {
            if index == 0 {
                r1 = element
            } else if index == 1 {
                r2 = element
            } else {
                r3 = element
            }
        }
        let model = TransitViewModel(firstRoute: r1, secondRoute: r2, thirdRoute: r3, slotBeingChanged: state.transitViewModel.slotBeingChanged)
        return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model, locations: state.vehicleLocations, refreshRoutes: false, refreshVehicleLocations: true)
    }
}
