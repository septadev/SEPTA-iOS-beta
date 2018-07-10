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
    
    init(availableRoutes: [TransitRoute] = [], transitViewModel: TransitViewModel = TransitViewModel()) {
        self.availableRoutes = availableRoutes
        self.transitViewModel = transitViewModel
    }
}

extension TransitViewState: Equatable {}
func == (lhs: TransitViewState, rhs: TransitViewState) -> Bool {
    return (lhs.availableRoutes == rhs.availableRoutes) &&
            (lhs.transitViewModel == rhs.transitViewModel)
}
