//
//  TransitType+TransitMode.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule

extension TransitType {

    static func fromTransitMode(_ transitMode: TransitMode) -> TransitType {
        switch transitMode {
        case .bus:
            return .BUS
        case .rail:
            return .RAIL
        case .subway:
            return .SUBWAY
        case .nhsl:
            return .NHSL
        case .trolley:
            return .TROLLEY
        }
    }
}
