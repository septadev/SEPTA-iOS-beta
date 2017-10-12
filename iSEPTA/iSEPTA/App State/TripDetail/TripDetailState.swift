//
//  TripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct TripDetailState {
    let tripDetails: NextToArriveStop?
    var tripDetailsExist: Bool { return tripDetails != nil }

    init(tripDetails: NextToArriveStop? = nil) {
        self.tripDetails = tripDetails
    }
}

extension TripDetailState: Equatable {}
func ==(lhs: TripDetailState, rhs: TripDetailState) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.tripDetails, newValue: rhs.tripDetails).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
