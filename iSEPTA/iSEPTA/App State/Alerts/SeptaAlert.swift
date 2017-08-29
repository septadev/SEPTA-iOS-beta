//
//  SeptaAlert.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct SeptaAlert {
    let advisory: Bool
    let alert: Bool
    let detour: Bool
    let weather: Bool

    init(advisory: Bool, alert: Bool, detour: Bool, weather: Bool) {
        self.advisory = advisory
        self.alert = alert
        self.detour = detour
        self.weather = weather
    }
}

extension SeptaAlert: Equatable {}
func ==(lhs: SeptaAlert, rhs: SeptaAlert) -> Bool {
    var areEqual = true

    areEqual = lhs.advisory == rhs.advisory
    guard areEqual else { return false }

    areEqual = lhs.alert == rhs.alert
    guard areEqual else { return false }

    areEqual = lhs.detour == rhs.detour
    guard areEqual else { return false }

    areEqual = lhs.weather == rhs.weather
    guard areEqual else { return false }

    return areEqual
}
