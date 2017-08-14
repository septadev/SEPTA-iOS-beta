//
//  TransitMode.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

extension TransitMode {

    func routeTitle() -> String {
        switch self {
        case .bus:
            return "Select Bus Route"
        case .rail:
            return "Select Rail Line"
        case .subway:
            return "Select Subway Line"
        case .trolley:
            return "Select Trolley Line"
        case .nhsl:
            return "Select NHSL Line"
        }
    }

    func selectRouteTitle() -> String {
        switch self {
        case .bus:
            return "Select Route"
        default:
            return "Select Line"
        }
    }
}
