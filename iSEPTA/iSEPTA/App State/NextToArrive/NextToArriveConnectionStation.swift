//
//  NextToArriveConnectionStation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct NextToArriveConnectionStation {
    let stopId: Int?
    let stopName: String

    init(stopId: Int?, stopName: String) {
        self.stopId = stopId
        self.stopName = stopName
    }
}

extension NextToArriveConnectionStation: Equatable {}
func ==(lhs: NextToArriveConnectionStation, rhs: NextToArriveConnectionStation) -> Bool {
    var areEqual = true

    areEqual = lhs.stopName == rhs.stopName
    guard areEqual else { return false }

    return areEqual
}
