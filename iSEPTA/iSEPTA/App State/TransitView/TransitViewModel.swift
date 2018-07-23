//
//  TransitViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct TransitViewModel {
    let firstRoute: TransitRoute?
    let secondRoute: TransitRoute?
    let thirdRoute: TransitRoute?
    let slotBeingChanged: TransitViewRouteSlot?
    
    init(firstRoute: TransitRoute? = nil, secondRoute: TransitRoute? = nil, thirdRoute: TransitRoute? = nil, slotBeingChanged: TransitViewRouteSlot? = nil) {
        self.firstRoute = firstRoute
        self.secondRoute = secondRoute
        self.thirdRoute = thirdRoute
        self.slotBeingChanged = slotBeingChanged
    }
}

enum TransitViewRouteSlot: Int {
    case first = 1
    case second = 2
    case third = 3
}

extension TransitViewModel: Equatable {}
func == (lhs: TransitViewModel, rhs: TransitViewModel) -> Bool {
    
    return
            (lhs.firstRoute == rhs.firstRoute) &&
            (lhs.secondRoute == rhs.secondRoute) &&
            (lhs.thirdRoute == rhs.thirdRoute) &&
            (lhs.slotBeingChanged == rhs.slotBeingChanged)
}
