//
//  TransitMode+NextToArriveDetail.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension TransitMode {

    func useRailForDetails() -> Bool {
        return [.rail].contains(self)
    }

    func useBusForDetails() -> Bool {
        return [.bus, .nhsl, .trolley].contains(self)
    }
}
