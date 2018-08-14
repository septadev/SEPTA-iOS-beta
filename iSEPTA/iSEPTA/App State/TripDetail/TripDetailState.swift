//
//  TripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct TripDetailState: Equatable {
    let tripDetails: NextToArriveStop?
    var tripDetailsExist: Bool { return tripDetails != nil }
    var lastUpdated: Date {
        guard let tripDetails = tripDetails else { return Date.distantPast }
        return tripDetails.updatedTime
    }

    init(tripDetails: NextToArriveStop? = nil) {
        self.tripDetails = tripDetails
    }
}
