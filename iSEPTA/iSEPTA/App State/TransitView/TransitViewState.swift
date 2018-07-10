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
    let selectedRoutes: [TransitRoute]
    
    init(availableRoutes: [TransitRoute] = [], selectedRoutes: [TransitRoute] = []) {
        self.availableRoutes = availableRoutes
        self.selectedRoutes = selectedRoutes
    }
}

extension TransitViewState: Equatable {}
func == (lhs: TransitViewState, rhs: TransitViewState) -> Bool {
    
    return
        (lhs.availableRoutes == rhs.availableRoutes) &&
        (lhs.selectedRoutes == rhs.selectedRoutes)
    
}
