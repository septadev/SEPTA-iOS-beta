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
            return TransitViewState(availableRoutes: action.routes, selectedRoutes: state.selectedRoutes)
        }
        
        if let action = action as? TransitViewRouteSelected {
            if state.selectedRoutes.count == 3 {
                return state
            }
            var selectedRoutes = state.selectedRoutes
            selectedRoutes.append(action.route)
            return TransitViewState(availableRoutes: state.availableRoutes, selectedRoutes: selectedRoutes)
        }
        
        if action is ResetTransitView {
            return TransitViewState(availableRoutes: state.availableRoutes, selectedRoutes: [])
        }
        
        return state
    }
}
