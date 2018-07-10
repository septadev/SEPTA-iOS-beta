//
//  TransitViewReducer.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift

struct TransitViewReducer {
    static func main(action: Action, state: TransitViewState?) -> TransitViewState {
        if let state = state {
            return reduceTransitViewState(action: action, state: state)
        } else {
            return TransitViewState()
        }
    }
    
    static func reduceTransitViewState(action: Action, state: TransitViewState) -> TransitViewState {
        guard let action = action as? TransitViewAction else { return state }
        
        if let action = action as? TransitViewRoutesLoaded {
            return TransitViewState(availableRoutes: action.routes, transitViewModel: state.transitViewModel)
        }
        
        if let action = action as? TransitViewRouteSelected {
            let first = action.slot == .first ? action.route : state.transitViewModel.firstRoute
            let second = action.slot == .second ? action.route : state.transitViewModel.secondRoute
            let third = action.slot == .third ? action.route : state.transitViewModel.thirdRoute
            let model = TransitViewModel(firstRoute: first, secondRoute: second, thirdRoute: third, slotBeingChanged: state.transitViewModel.slotBeingChanged)
            return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model)
        }
        
        if action is ResetTransitView {
            return TransitViewState(availableRoutes: state.availableRoutes)
        }
        
        if let action = action as? TransitViewSlotChange {
            let model = TransitViewModel(firstRoute: state.transitViewModel.firstRoute, secondRoute: state.transitViewModel.secondRoute, thirdRoute: state.transitViewModel.thirdRoute, slotBeingChanged: action.slot)
            return TransitViewState(availableRoutes: state.availableRoutes, transitViewModel: model)
        }
        
        return state
    }
}
